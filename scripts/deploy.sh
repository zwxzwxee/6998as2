echo "S3 Bucket: $S3_BUCKET"
echo "Lambda Function One Name: $LAMBDA_FUNCTION_NAME_ONE"
echo "Lambda Function Two Name: $LAMBDA_FUNCTION_NAME_TWO"
echo "Lambda Deployment Preference: $LAMBDA_DEPLOYMENT_PREFERENCE"

TARGET_LAMBDA_FUNCTION_CODE_ONE="index-photos.zip"
cd function/index-photos
zip -r ${TARGET_LAMBDA_FUNCTION_CODE_ONE} *
aws s3 cp ${TARGET_LAMBDA_FUNCTION_CODE_ONE} s3://${S3_BUCKET}/

TARGET_LAMBDA_FUNCTION_CODE_TWO="search-photos.zip"
cd ../search-photos
zip -r ${TARGET_LAMBDA_FUNCTION_CODE_TWO} *
aws s3 cp ${TARGET_LAMBDA_FUNCTION_CODE_TWO} s3://${S3_BUCKET}/
