"""
Claims service for DynamoDB + S3 hybrid storage
Implements healthcare claims persistence with audit trails
"""

import json
import logging
from datetime import datetime, timedelta
from typing import Optional

import boto3
from botocore.exceptions import ClientError

from ..config.settings import get_settings
from ..models.healthcare_claim import HealthcareClaim, ClaimStatus
from ..models.validation_result import ValidationResult
from ..utils.decorators import handle_errors, audit_trail

logger = logging.getLogger(__name__)
settings = get_settings()


class ClaimsService:
    """
    Service for managing healthcare claims with DynamoDB + S3 hybrid storage
    Metadata in DynamoDB for fast queries, documents in S3 for cost optimization
    """

    def __init__(self):
        aws_config = settings.get_aws_config()
        self.dynamodb = boto3.resource('dynamodb', **aws_config)
        self.s3_client = boto3.client('s3', **aws_config)
        
        # DynamoDB tables
        self.claims_table = self.dynamodb.Table(settings.DYNAMODB_CLAIMS_TABLE)
        self.results_table = self.dynamodb.Table(settings.DYNAMODB_RESULTS_TABLE)
        self.sessions_table = self.dynamodb.Table(settings.DYNAMODB_SESSIONS_TABLE)

    @handle_errors
    @audit_trail("STORE_CLAIM")
    async def store_claim(self, claim: HealthcareClaim) -> bool:
        """
        Store healthcare claim with DynamoDB metadata + S3 document
        
        Args:
            claim: HealthcareClaim object to store
            
        Returns:
            True if successful
        """
        try:
            # Store full claim document in S3
            s3_key = f"{settings.S3_CLAIMS_PREFIX}{claim.claim_id}.json"
            claim_document = claim.to_dict()
            
            self.s3_client.put_object(
                Bucket=settings.S3_BUCKET_NAME,
                Key=s3_key,
                Body=json.dumps(claim_document, default=str),
                ContentType='application/json',
                ServerSideEncryption='AES256',
                Metadata={
                    'claim_id': claim.claim_id,
                    'patient_id': claim.patient_id,  # De-identified
                    'procedure_code': claim.procedure_code,
                    'created_at': datetime.utcnow().isoformat()
                }
            )
            
            # Store metadata in DynamoDB for fast queries
            ttl_timestamp = int((datetime.utcnow() + timedelta(days=7)).timestamp())
            
            self.claims_table.put_item(
                Item={
                    'claim_id': claim.claim_id,
                    'status': claim.status.value,
                    'patient_id': claim.patient_id,
                    'provider_id': claim.provider_id,
                    'service_date': claim.service_date.isoformat(),
                    'procedure_code': claim.procedure_code,
                    'diagnosis_code': claim.diagnosis_code,
                    'claim_amount': claim.claim_amount,
                    'priority': claim.priority.value,
                    'submitted_at': claim.submitted_at.isoformat(),
                    's3_document_path': s3_key,
                    'ttl': ttl_timestamp,
                    'created_at': datetime.utcnow().isoformat(),
                    'updated_at': datetime.utcnow().isoformat()
                }
            )
            
            logger.info(
                "claim_stored_successfully",
                claim_id=claim.claim_id,
                s3_key=s3_key,
                ttl_days=7
            )
            
            return True
            
        except ClientError as e:
            logger.error(f"AWS error storing claim {claim.claim_id}: {str(e)}")
            raise
        except Exception as e:
            logger.error(f"Error storing claim {claim.claim_id}: {str(e)}")
            raise

    @handle_errors
    async def get_claim(self, claim_id: str) -> Optional[HealthcareClaim]:
        """
        Retrieve healthcare claim by ID
        
        Args:
            claim_id: Unique claim identifier
            
        Returns:
            HealthcareClaim object or None if not found
        """
        try:
            # Get metadata from DynamoDB
            response = self.claims_table.get_item(
                Key={'claim_id': claim_id}
            )
            
            if 'Item' not in response:
                logger.warning(f"Claim {claim_id} not found in DynamoDB")
                return None
            
            metadata = response['Item']
            
            # Get full document from S3
            s3_key = metadata.get('s3_document_path')
            if s3_key:
                try:
                    s3_response = self.s3_client.get_object(
                        Bucket=settings.S3_BUCKET_NAME,
                        Key=s3_key
                    )
                    claim_data = json.loads(s3_response['Body'].read())
                    return HealthcareClaim.parse_obj(claim_data)
                except ClientError as e:
                    if e.response['Error']['Code'] == 'NoSuchKey':
                        logger.warning(f"S3 document not found for claim {claim_id}: {s3_key}")
                    else:
                        raise
            
            # Fallback: reconstruct from DynamoDB metadata
            claim_data = {
                'claim_id': metadata['claim_id'],
                'patient_id': metadata['patient_id'],
                'provider_id': metadata['provider_id'],
                'service_date': metadata['service_date'],
                'procedure_code': metadata['procedure_code'],
                'diagnosis_code': metadata['diagnosis_code'],
                'claim_amount': metadata['claim_amount'],
                'status': metadata['status'],
                'submitted_at': metadata['submitted_at'],
                'priority': metadata['priority']
            }
            
            return HealthcareClaim.parse_obj(claim_data)
            
        except ClientError as e:
            logger.error(f"AWS error retrieving claim {claim_id}: {str(e)}")
            raise
        except Exception as e:
            logger.error(f"Error retrieving claim {claim_id}: {str(e)}")
            raise

    @handle_errors
    @audit_trail("UPDATE_CLAIM_STATUS")
    async def update_claim_status(self, claim_id: str, new_status: ClaimStatus) -> bool:
        """
        Update claim status in DynamoDB
        
        Args:
            claim_id: Unique claim identifier
            new_status: New claim status
            
        Returns:
            True if successful
        """
        try:
            self.claims_table.update_item(
                Key={'claim_id': claim_id},
                UpdateExpression='SET #status = :status, updated_at = :updated_at',
                ExpressionAttributeNames={
                    '#status': 'status'
                },
                ExpressionAttributeValues={
                    ':status': new_status.value,
                    ':updated_at': datetime.utcnow().isoformat()
                }
            )
            
            logger.info(
                "claim_status_updated",
                claim_id=claim_id,
                new_status=new_status.value
            )
            
            return True
            
        except ClientError as e:
            logger.error(f"AWS error updating claim status {claim_id}: {str(e)}")
            raise

    @handle_errors
    @audit_trail("STORE_VALIDATION_RESULT")
    async def store_validation_result(self, result: ValidationResult) -> bool:
        """
        Store validation result with DynamoDB metadata + S3 document
        
        Args:
            result: ValidationResult object to store
            
        Returns:
            True if successful
        """
        try:
            # Store full result document in S3
            s3_key = f"{settings.S3_RESULTS_PREFIX}{result.result_id}.json"
            result_document = result.to_dict()
            
            self.s3_client.put_object(
                Bucket=settings.S3_BUCKET_NAME,
                Key=s3_key,
                Body=json.dumps(result_document, default=str),
                ContentType='application/json',
                ServerSideEncryption='AES256',
                Metadata={
                    'result_id': result.result_id,
                    'claim_id': result.claim_id,
                    'validation_status': result.validation_status.value,
                    'created_at': result.created_at.isoformat()
                }
            )
            
            # Store metadata in DynamoDB
            ttl_timestamp = int((datetime.utcnow() + timedelta(days=7)).timestamp())
            
            self.results_table.put_item(
                Item={
                    'result_id': result.result_id,
                    'claim_id': result.claim_id,
                    'validation_status': result.validation_status.value,
                    'confidence_score': result.confidence_score,
                    'cost_reduction': result.cost_reduction,
                    'processing_time_ms': result.processing_time_ms,
                    'requires_human_review': result.requires_human_review,
                    'compliance_checks_passed': sum(1 for check in result.compliance_checks if check.passed),
                    'total_compliance_checks': len(result.compliance_checks),
                    's3_document_path': s3_key,
                    'ttl': ttl_timestamp,
                    'created_at': result.created_at.isoformat()
                }
            )
            
            logger.info(
                "validation_result_stored_successfully",
                result_id=result.result_id,
                claim_id=result.claim_id,
                s3_key=s3_key
            )
            
            return True
            
        except ClientError as e:
            logger.error(f"AWS error storing validation result {result.result_id}: {str(e)}")
            raise
        except Exception as e:
            logger.error(f"Error storing validation result {result.result_id}: {str(e)}")
            raise

    @handle_errors
    async def get_validation_result(self, claim_id: str) -> Optional[ValidationResult]:
        """
        Retrieve validation result by claim ID
        
        Args:
            claim_id: Claim identifier
            
        Returns:
            ValidationResult object or None if not found
        """
        try:
            # Query DynamoDB by claim_id (GSI)
            response = self.results_table.query(
                IndexName='claim-id-index',
                KeyConditionExpression='claim_id = :claim_id',
                ExpressionAttributeValues={':claim_id': claim_id},
                ScanIndexForward=False,  # Get most recent
                Limit=1
            )
            
            if not response.get('Items'):
                return None
            
            metadata = response['Items'][0]
            
            # Get full document from S3
            s3_key = metadata.get('s3_document_path')
            if s3_key:
                try:
                    s3_response = self.s3_client.get_object(
                        Bucket=settings.S3_BUCKET_NAME,
                        Key=s3_key
                    )
                    result_data = json.loads(s3_response['Body'].read())
                    return ValidationResult.parse_obj(result_data)
                except ClientError as e:
                    if e.response['Error']['Code'] == 'NoSuchKey':
                        logger.warning(f"S3 document not found for result: {s3_key}")
                    else:
                        raise
            
            return None
            
        except ClientError as e:
            logger.error(f"AWS error retrieving validation result for claim {claim_id}: {str(e)}")
            raise
        except Exception as e:
            logger.error(f"Error retrieving validation result for claim {claim_id}: {str(e)}")
            raise