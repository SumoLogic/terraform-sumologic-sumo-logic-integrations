package common

import (
	"fmt"
	"testing"

	aws_sdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/sns"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/stretchr/testify/assert"
)

type AwsResourcesAssert struct{}

func (a *AwsResourcesAssert) AWS_SNS_TOPIC(t *testing.T, region string, value interface{}) {
	fmt.Println("******** Asserting AWS SNS Topics ********")
	arns := getArns(value)
	snsClient := aws.NewSnsClient(t, region)
	for element := range arns {
		input := sns.GetTopicAttributesInput{TopicArn: aws_sdk.String(arns[element])}
		_, err := snsClient.GetTopicAttributes(&input)
		if err != nil {
			assert.Equal(t, err, "NotFound", fmt.Sprintf("SNS Topic %v not created in AWS account", arns[element]))
		}
	}
}

func getArns(value interface{}) []string {
	var arns []string
	mapValue := value.(map[string]interface{})
	arn, found := mapValue["arn"]
	if found {
		arns = append(arns, arn.(string))
	} else {
		for key, currentValue := range mapValue {
			fmt.Println("Searching for ARN in terraform resource { " + key + " }.")
			arn, found := currentValue.(map[string]interface{})["arn"]
			if found {
				arns = append(arns, arn.(string))
			}
		}
	}
	return arns
}
