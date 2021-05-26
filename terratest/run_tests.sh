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
  if eval $cmd; then
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

    AWS_PROFILE=${AWS_DEFAULT_PROFILE} go test -v -timeout 30m ./${module} | tee ${module}/test.log
    
    echo "\nIntegration tests Completed.\n" 
}

##################################### START OF THE TEST CASES #####################################
# 1. Set some Environment variables
export SUMOLOGIC_ENVIRONMENT=
export SUMOLOGIC_ACCESS_ID=
export SUMOLOGIC_ACCESS_KEY=
export SUMOLOGIC_ORG_ID=
export AWS_REGION=
export AWS_DEFAULT_PROFILE=

# 2. Deccalring the modules. Please update the array, if some new modules are added.
declare -a modules=(
    "aws/cloudtrail"
)

# 3. Iterating through the module array to run unit and integration test cases.
for module in "${modules[@]}"
do
    echo "**************************** Running Tests for the \"$module\" module. ****************************\n"
    export MODULE_DIRECTORY=${module}
    unit_test ${module}
    integration_test ${module}
    echo "**************************** Completed Tests for the \"$module\" module. ****************************\n"
done