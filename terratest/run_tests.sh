#!/bin/sh

# Function to check commands for terraform and tflint.
function check_command()
{
    local cmd="$1"
    if ! command -v ${cmd} > /dev/null 2>&1; then
        echo "This requires ${cmd} command, please install it first."
        if [[ "$1" == "terraform" ]]; then
            echo "You can install using this command on Mac: brew install terraform, Windows: choco install terraform and by downloading binary on other systems."
        elif [[ "$1" == "tflint" ]]; then
            echo "You can install using this command on Mac: brew install tflint, Windows: choco install tflint and by downloading binary on other systems."
        fi
        exit 1
    fi
}

# Function to validate commands.
function validate_command()
{
  local cmd="$1"
  # Capture both stdout and stderr
  local output
  output=$(eval "$cmd" 2>&1)
  local status=$?

  # Print the command output
  echo "-----------------------------"
  echo "output : $output"
  echo "status : $status"
  echo "-----------------------------"

  if [ $status -eq 0 ]; then
    echo "\"$cmd\" worked Successfully."
  else
    echo "\"$cmd\" failed. Please check the error as printed in the command line, correct it and re-run the tests again."
    exit 1
  fi
}

# Function to unit tests
function unit_test()
{
    echo "1. Running unit tests ..........................\n"
    for cmd in terraform tflint; 
    do
        echo -e "\t- Check command \"$cmd\" exists."
        check_command $cmd
    done
    
    validate_command "tflint"
    validate_command "terraform fmt -recursive -write=false -diff=true -check=true ../${module}"
    
    echo "\nUnit tests Completed.\n"
}

# Function to integration test
function integration_test()
{
    echo "2. Running integration tests ........................\n"

    AWS_PROFILE=${AWS_DEFAULT_PROFILE} go test -v -timeout 60m ./${module} | tee ${module}/test.log
    ## Use below command to run single testcase
    #AWS_PROFILE=${AWS_DEFAULT_PROFILE} go test -v -timeout 60m ./${module} -run ^TestUpdatesOnly$
    ## Note: use below command for debugging
    #AWS_PROFILE=${AWS_DEFAULT_PROFILE} dlv test ./aws/cloudtrail -- -test.run '^TestWithExistingTrailNewBucketCollectorSNSIAM' -test.v -test.timeout 360m
    echo "\nIntegration tests Completed.\n" 
}

# Fucntion to setup env variables specific to module
function set_env_variables()
{
    local type="$1"
    if [[ "${type}" = *"cloudtrail"* ]];then
        echo "Setting env variables for ${type}"
        export BUCKET_NAME="<YourS3BucketName>"
        export PATH_EXPRESSION="AWSLogs/<AWS_ACCOUNT_ID>/CloudTrail/us-east-1/*"
        export IAM_ROLE="arn:aws:iam::<AWS_ACCOUNT_ID>:role/TestingTerraformCloudTrailRole"
        export TOPIC_ARN="arn:aws:sns:us-east-1:<AWS_ACCOUNT_ID>:dynamodb"
        export COLLECTOR_ID="<COLLECTOR_ID>"
    elif [[ "${type}" = *"sumologic"* ]];then
        echo "Setting env variables for ${type}"
    elif [[ "${type}" = *"cloudwatchmetrics"* ]];then 
        echo "Setting env variables for ${type}"
        export IAM_ROLE="arn:aws:iam::<AWS_ACCOUNT_ID>:role/TestingTerraformCloudTrailRole"
        export COLLECTOR_ID="<COLLECTOR_ID>"
    elif [[ "${type}" = *"elb"* ]];then
        echo "Setting env variables for ${type}"
        export BUCKET_NAME_US_WEST_1="<YourS3BucketName>-us-west-1"
        export PATH_EXPRESSION_US_WEST_1="*AWSLogs/<AWS_ACCOUNT_ID>/elasticloadbalancing/us-west-1/*"
        export TOPIC_ARN_US_WEST_1="arn:aws:sns:us-west-1:<AWS_ACCOUNT_ID>:dynamodb"
        export BUCKET_NAME_AP_SOUTH_1="<YourS3BucketName>-ap-south-1"
        export PATH_EXPRESSION_AP_SOUTH_1="*AWSLogs/<AWS_ACCOUNT_ID>/elasticloadbalancing/ap-south-1/*"
        export IAM_ROLE="arn:aws:iam::<AWS_ACCOUNT_ID>:role/TestingTerraformCloudTrailRole"
        export COLLECTOR_ID="<COLLECTOR_ID>"
    elif [[ "${type}" = *"kinesisfirehoseforlogs"* ]];then
        echo "Setting env variables for ${type}"
        export BUCKET_NAME_US_WEST_1="<YourS3BucketName>-us-west-1"
        export COLLECTOR_ID="<COLLECTOR_ID>"
    elif [[ "${type}" = *"kinesisfirehoseformetrics"* ]];then
        echo "Setting env variables for ${type}"
        export BUCKET_NAME_US_WEST_1="<YourS3BucketName>-us-west-1"
        export BUCKET_NAME_AP_SOUTH_1="<YourS3BucketName>-ap-south-1"
        export IAM_ROLE="arn:aws:iam::<AWS_ACCOUNT_ID>:role/TestingTerraformCloudTrailRole"
        export COLLECTOR_ID="<COLLECTOR_ID>"
    elif [[ "${type}" = *"rootcause"* ]];then
        echo "Setting env variables for ${type}"
        export IAM_ROLE="arn:aws:iam::<AWS_ACCOUNT_ID>:role/TestingTerraformCloudTrailRole"
        export COLLECTOR_ID="<COLLECTOR_ID>"
    elif [[ "${type}" = *"cloudwatchlogsforwarder"* ]];then
        echo "Setting env variables for ${type}"
        export COLLECTOR_ID="<COLLECTOR_ID>"
    else
        echo "No Matching Module found to set up env variables."
    fi
}

##################################### START OF THE TEST CASES #####################################
# 1. Set some Environment variables
export SUMOLOGIC_ENVIRONMENT=
export SUMOLOGIC_ACCESS_ID=
export SUMOLOGIC_ACCESS_KEY=
export SUMOLOGIC_ORG_ID=
export AWS_DEFAULT_PROFILE=
export AWS_PROFILE=

# 2. Declaring the modules. Please update the array, if some new modules are added.
# Deprecated "aws/rootcause" - https://help.sumologic.com/release-notes-service/2025/06/03/observability/
declare -a modules=(
    "aws/cloudtrail" "aws/elb" "aws/cloudwatchmetrics" "aws/kinesisfirehoseforlogs" "aws/kinesisfirehoseformetrics" "aws/cloudwatchlogsforwarder" "sumologic"
)

# 3. Iterating through the module array to run unit and integration test cases.
for module in "${modules[@]}"
do
    echo "**************************** Running Tests for the \"$module\" module. ****************************\n"
    export MODULE_DIRECTORY=${module}
    unit_test ${module}
    set_env_variables ${module}
    integration_test ${module}
    echo "**************************** Completed Tests for the \"$module\" module. ****************************\n"
done