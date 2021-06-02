package common

import (
	"fmt"

	aws_sdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cloudtrail"
	"github.com/aws/aws-sdk-go/service/iam"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/sns"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/stretchr/testify/assert"
)

func (a *ResourcesAssert) AWS_SNS_TOPIC(value interface{}) {
	fmt.Println("******** Asserting AWS SNS TOPICS ********")
	arns := getKeyValuesFromData(value, "arn")
	snsClient := aws.NewSnsClient(a.t, a.AwsRegion)
	for _, element := range arns {
		input := sns.GetTopicAttributesInput{TopicArn: aws_sdk.String(element)}
		_, err := snsClient.GetTopicAttributes(&input)
		assert.NoErrorf(a.t, err, "AWS SNS TOPIC :- Error Message %v", err)
	}
}

func (a *ResourcesAssert) AWS_S3_BUCKET(value interface{}) {
	fmt.Println("******** Asserting AWS S3 BUCKETS ********")
	bucket_names := getKeyValuesFromData(value, "bucket")
	for _, element := range bucket_names {
		bucket_arn := aws_sdk.String(element)
		aws.AssertS3BucketExists(a.t, a.AwsRegion, *bucket_arn)
	}
}

func (a *ResourcesAssert) AWS_IAM_ROLE(value interface{}) {
	fmt.Println("******** Asserting AWS IAM ROLES ********")
	names := getKeyValuesFromData(value, "name")
	iamClient := aws.NewIamClient(a.t, a.AwsRegion)
	for _, element := range names {
		input := iam.GetRoleInput{RoleName: aws_sdk.String(element)}
		_, err := iamClient.GetRole(&input)
		assert.NoErrorf(a.t, err, "AWS IAM ROLE :- Error Message %v", err)
	}
}

func (a *ResourcesAssert) AWS_SNS_SUBSCRIPTION(value interface{}) {
	fmt.Println("******** Asserting AWS SNS SUBSCRIPTION ********")
	arns := getKeyValuesFromData(value, "arn")
	snsClient := aws.NewSnsClient(a.t, a.AwsRegion)
	for _, element := range arns {
		input := sns.GetSubscriptionAttributesInput{SubscriptionArn: aws_sdk.String(element)}
		_, err := snsClient.GetSubscriptionAttributes(&input)
		assert.NoErrorf(a.t, err, "AWS SNS SUBSCRIPTION :- Error Message %v", err)
	}
}

func (a *ResourcesAssert) AWS_CLOUDTRAIL(value interface{}) {
	fmt.Println("******** Asserting AWS CLOUDTRAILS ********")
	names := getKeyValuesFromData(value, "name")
	mySession := session.Must(session.NewSession())
	svc := cloudtrail.New(mySession, aws_sdk.NewConfig().WithRegion(a.AwsRegion))
	for _, element := range names {
		input := cloudtrail.GetTrailInput{Name: aws_sdk.String(element)}
		_, err := svc.GetTrail(&input)
		assert.NoErrorf(a.t, err, "AWS CLOUDTRAIl :- Error Message %v", err)
	}
}

func (a *ResourcesAssert) AWS_S3_BUCKET_NOTIFICATION(value interface{}) {
	fmt.Println("******** Asserting AWS S3 BUCKET NOTIFICATION ********")
	bucket_names := getKeyValuesFromData(value, "bucket")

	s3_client := aws.NewS3Client(a.t, a.AwsRegion)

	for _, element := range bucket_names {
		input := s3.GetBucketNotificationConfigurationRequest{Bucket: aws_sdk.String(element)}
		notificationConfiguration, err := s3_client.GetBucketNotificationConfiguration(&input)
		assert.NoErrorf(a.t, err, "AWS S3 Bucket NOTIFICATION :- Error Message %v", err)
		assert.Greater(a.t, len(notificationConfiguration.TopicConfigurations), 0, "No topic configuration present in the Bucket.")
	}
}
