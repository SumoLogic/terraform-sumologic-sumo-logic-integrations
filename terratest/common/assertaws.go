package common

import (
	"fmt"
	"testing"

	aws_sdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cloudtrail"
	"github.com/aws/aws-sdk-go/service/iam"
	"github.com/aws/aws-sdk-go/service/sns"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/stretchr/testify/assert"
)

func (a *ResourcesAssert) AWS_SNS_TOPIC(t *testing.T, value interface{}) {
	fmt.Println("******** Asserting AWS SNS TOPICS ********")
	arns := getKeyValuesFromData(value, "arn")
	snsClient := aws.NewSnsClient(t, a.AwsRegion)
	for _, element := range arns {
		input := sns.GetTopicAttributesInput{TopicArn: aws_sdk.String(element)}
		_, err := snsClient.GetTopicAttributes(&input)
		assert.NoErrorf(t, err, "AWS SNS TOPIC :- Error Message %v", err)
	}
}

func (a *ResourcesAssert) AWS_S3_BUCKET(t *testing.T, value interface{}) {
	fmt.Println("******** Asserting AWS S3 BUCKETS ********")
	bucket_names := getKeyValuesFromData(value, "bucket")
	for _, element := range bucket_names {
		bucket_arn := aws_sdk.String(element)
		aws.AssertS3BucketExists(t, a.AwsRegion, *bucket_arn)
	}
}

func (a *ResourcesAssert) AWS_IAM_ROLE(t *testing.T, value interface{}) {
	fmt.Println("******** Asserting AWS IAM ROLES ********")
	names := getKeyValuesFromData(value, "name")
	iamClient := aws.NewIamClient(t, a.AwsRegion)
	for _, element := range names {
		input := iam.GetRoleInput{RoleName: aws_sdk.String(element)}
		_, err := iamClient.GetRole(&input)
		assert.NoErrorf(t, err, "AWS IAM ROLE :- Error Message %v", err)
	}
}

func (a *ResourcesAssert) AWS_SNS_SUBSCRIPTION(t *testing.T, value interface{}) {
	fmt.Println("******** Asserting AWS SNS SUBSCRIPTION ********")
	arns := getKeyValuesFromData(value, "arn")
	snsClient := aws.NewSnsClient(t, a.AwsRegion)
	for _, element := range arns {
		input := sns.GetSubscriptionAttributesInput{SubscriptionArn: aws_sdk.String(element)}
		_, err := snsClient.GetSubscriptionAttributes(&input)
		assert.NoErrorf(t, err, "AWS SNS SUBSCRIPTION :- Error Message %v", err)
	}
}

func (a *ResourcesAssert) AWS_CLOUDTRAIL(t *testing.T, value interface{}) {
	fmt.Println("******** Asserting AWS CLOUDTRAILS ********")
	names := getKeyValuesFromData(value, "name")
	mySession := session.Must(session.NewSession())
	svc := cloudtrail.New(mySession, aws_sdk.NewConfig().WithRegion(a.AwsRegion))
	for _, element := range names {
		input := cloudtrail.GetTrailInput{Name: aws_sdk.String(element)}
		_, err := svc.GetTrail(&input)
		assert.NoErrorf(t, err, "AWS CLOUDTRAIl :- Error Message %v", err)
	}
}
