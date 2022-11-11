echo "S3 Bucket: $S3_BUCKET"
echo "Lambda Function One Name: $LAMBDA_FUNCTION_NAME_ONE"
echo "Lambda Function Two Name: $LAMBDA_FUNCTION_NAME_TWO"
echo "Lambda Deployment Preference: $LAMBDA_DEPLOYMENT_PREFERENCE"

# FUNCTION_EXISTS=$(aws lambda wait function-exists --function-name ${LAMBDA_FUNCTION_NAME})
# EXIT_STATUS=$?

# if [ $EXIT_STATUS -ne 0 ]; then
#   echo "The function doesn't exist yet. Creating it..."
#   TARGET_LAMBDA_FUNCTION_VERSION=1
#   echo "Target Version: ${TARGET_LAMBDA_FUNCTION_VERSION}"
# else
#   CURRENT_LAMBDA_FUNCTION_VERSION=$(aws lambda list-versions-by-function --function-name ${LAMBDA_FUNCTION_NAME} --query "Versions[-1].[Version]" | grep -o -E '[0-9]+')
#   echo "New Current Version: ${CURRENT_LAMBDA_FUNCTION_VERSION}"
#   ((CURRENT_LAMBDA_FUNCTION_VERSION++))
#   TARGET_LAMBDA_FUNCTION_VERSION=${CURRENT_LAMBDA_FUNCTION_VERSION}
#   echo "tried incrementing"
#   echo "Target Version: ${TARGET_LAMBDA_FUNCTION_VERSION}"
# fi

TARGET_LAMBDA_FUNCTION_CODE_ONE="LF1.zip"
cd function/index-photos
zip -FSr ./${TARGET_LAMBDA_FUNCTION_CODE_ONE}
aws s3 cp ${TARGET_LAMBDA_FUNCTION_CODE_ONE} s3://${S3_BUCKET}/

TARGET_LAMBDA_FUNCTION_CODE_TWO="LF2.zip"
cd ../search-photos
zip -FSr ./${TARGET_LAMBDA_FUNCTION_CODE_TWO}
aws s3 cp ${TARGET_LAMBDA_FUNCTION_CODE_TWO} s3://${S3_BUCKET}/

# cat >template.yaml <<EOM
# AWSTemplateFormatVersion: '2010-09-09'
# Transform: AWS::Serverless-2016-10-31
# Resources:
#   LambdaFunction:
#     Type: AWS::Serverless::Function
#     Properties:
#       FunctionName: ${LAMBDA_FUNCTION_NAME_ONE}, ${LAMBDA_FUNCTION_NAME_TWO}
#       Handler: lambda_function.lambda_handler
#       Runtime: python3.9
#       CodeUri: s3://${S3_BUCKET}/LF1.zip, s3://${S3_BUCKET}/LF2.zip
#       AutoPublishAlias: default
#       Timeout: 30
#       DeploymentPreference:
#         Enabled: True
#         Type: ${LAMBDA_DEPLOYMENT_PREFERENCE}
# EOM
# cat template.yaml
