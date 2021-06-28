# Test Modules

`terratest` folder contains GO test cases for AWS and Sumo Logic modules.

`run_tests.sh` is the shell script that runs the test cases for the all the modules.

## Test Design

Test cases have been divided  into Two parts :

###### Unit Tests
Unit tests checks for :

- `Terraform` installation
- `tflint` installation
- `terrafom fmt` to check for formatting across all the terraform files in the module folder.

###### Integration Tests

Integration test checks for :

- `terraform init and validate` to initialize and validate the terraform files.
- `terraform apply` to check across various test cases.
  - Test cases have been written based on various inputs that can impact terraform resource creation.
- Validate expected and actual resource create, changed and destroyed.
- Validate expected (this takes up a JSON file with expected outputs) and actual outputs from modules.
- Validate if the logs or metrics have been received in Sumo Logic.

## Testing

- Update the `run_tests.sh` to provide below environment variables
  - SUMOLOGIC_ENVIRONMENT -> Sumo Logic environment (au, ca, de, eu, jp, us1, us2, in, or fed).
  - SUMOLOGIC_ACCESS_ID -> Sumo Logic Access ID.
  - SUMOLOGIC_ACCESS_KEY -> Sumo Logic Access key.
  - SUMOLOGIC_ORG_ID -> Sumo Logic Organization ID.
  - AWS_DEFAULT_PROFILE -> AWS CLI Profile name.
  - AWS_PROFILE -> AWS CLI Profile name.
- Replace below variables in `set_env_variables` method with correct values in `run_tests.sh` from AWS account and Sumo Logic org.
  - BUCKET_NAME -> A Bucket from us-east-1 region
  - BUCKET_NAME_US_WEST_1 -> A Bucket from us-west-1 region.
  - BUCKET_NAME_AP_SOUTH_1 -> A Bucket from ap-south-1 region.
  - PATH_EXPRESSION -> A correct path expression to fetch logs.
  - PATH_EXPRESSION_US_WEST_1 -> A correct path expression to fetch logs.
  - PATH_EXPRESSION_AP_SOUTH_1 -> A correct path expression to fetch logs.
  - IAM_ROLE -> AN IAM role with CloudTrail, ELB, Metrics and Root Cause permissions.
  - TOPIC_ARN -> A SNS topic ARN from us-east-1 region.
  - TOPIC_ARN_US_WEST_1 -> A SNS topic ARN from us-west-1 region.
  - COLLECTOR_ID -> A Existing Sumo Logic hosted collector ID.
- One above 2 steps have been performed, run the test cases for the module you would like to test.
  - You can update the `modules` the variable in `run_tests.sh` file.
- A `test.log` file will be generated in the module's test folder.