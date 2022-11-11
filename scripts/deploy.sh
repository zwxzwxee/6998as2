echo "S3 Bucket: $S3_BUCKET"
echo "Lambda Function Name: $LAMBDA_FUNCTION_NAME"
echo "Lambda Deployment Preference: $LAMBDA_DEPLOYMENT_PREFERENCE"
# echo "GitHub Branch: $BRANCH"
#
# if [ "$BRANCH" == "master" ]; then
#     BRANCH="prod"
# fi

FUNCTION_EXISTS=$(aws lambda wait function-exists --function-name ${LAMBDA_FUNCTION_NAME})
EXIT_STATUS=$?
if [ $EXIT_STATUS -ne 0 ]; then
  echo "The function doesn't exist yet. Creating it..."
  TARGET_LAMBDA_FUNCTION_VERSION=1
  echo "Target Version: ${TARGET_LAMBDA_FUNCTION_VERSION}"
else
  CURRENT_LAMBDA_FUNCTION_VERSION=$(aws lambda list-versions-by-function --function-name ${LAMBDA_FUNCTION_NAME} --query "Versions[-1].[Version]" | grep -o -E '[0-9]+')
  echo "New Current Version: ${CURRENT_LAMBDA_FUNCTION_VERSION}"
  ((CURRENT_LAMBDA_FUNCTION_VERSION++))
  TARGET_LAMBDA_FUNCTION_VERSION=${CURRENT_LAMBDA_FUNCTION_VERSION}
  echo "tried incrementing"
  echo "Target Version: ${TARGET_LAMBDA_FUNCTION_VERSION}"
fi

TARGET_LAMBDA_FUNCTION_CODE="Build.zip"
zip -rj ${TARGET_LAMBDA_FUNCTION_CODE} function/*
aws s3 cp ${TARGET_LAMBDA_FUNCTION_CODE} s3://${S3_BUCKET}/master/

cat >template.yaml <<EOM
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Resources:
  LambdaFunction:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: ${LAMBDA_FUNCTION_NAME}
      Handler: lambda_function.lambda_handler
      Runtime: python3.7
      CodeUri: s3://${S3_BUCKET}/master/${LAMBDA_FUNCTION_NAME}_v${TARGET_LAMBDA_FUNCTION_VERSION}.zip
      AutoPublishAlias: default
      Timeout: 30
      DeploymentPreference:
        Enabled: True
        Type: ${LAMBDA_DEPLOYMENT_PREFERENCE}
EOM
cat template.yaml
