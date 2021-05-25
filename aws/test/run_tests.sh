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

##################################### START OF THE TEST CASES #####################################
# 1. Deccalring the modules. Please update the array, if some new modules are added.
declare -a modules = (
    "cloudtrail"
)

# 2. Iterating through the module array to run unit and integration test cases.
for module in "${modules[@]}"
do
    echo "**************************** Running Tests for the \"$module\" module. ****************************"
    echo "1. Running unit tests .........................."
    for cmd in terraform tflint; 
    do
        echo -e "\t- Check command \"$cmd\" exists."
        check_command $cmd
    done
    
    cd ../${module}

    validate_command "tflint"

    validate_command "terraform init"
    
    validate_command "terraform validate"

    validate_command "terraform fmt -write=false -diff=true -check=true"

    echo "Unit tests Completed."

    echo "2. Running integration tests ........................"
    
    go test -v -timeout 30m -run | tee test_output.log
    terratest_log_parser -testlog test_output.log -outputdir test_output
    
    echo "Integration tests Completed."

    cd ..    
done