package common

import (
	"fmt"

	aws_sdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cloudformation"
	"github.com/aws/aws-sdk-go/service/cloudtrail"
	"github.com/aws/aws-sdk-go/service/cloudwatchlogs"
	"github.com/aws/aws-sdk-go/service/firehose"
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

func (a *ResourcesAssert) AWS_CLOUDWATCH_LOG_GROUP(value interface{}) {
	fmt.Println("******** Asserting AWS CLOUDWATCH LOG GROUP ********")
	lg_names := getKeyValuesFromData(value, "name")

	cw_client := aws.NewCloudWatchLogsClient(a.t, a.AwsRegion)

	for _, element := range lg_names {
		output, err := cw_client.DescribeLogGroups(&cloudwatchlogs.DescribeLogGroupsInput{
			LogGroupNamePrefix: aws_sdk.String(element),
		})
		assert.NoErrorf(a.t, err, "AWS LOG GROUP :- Error Message %v", err)
		assert.Greater(a.t, len(output.LogGroups), 0, "No Log group found with the name ."+element)
	}
}

func (a *ResourcesAssert) AWS_CLOUDWATCH_LOG_STREAM(value interface{}) {
	fmt.Println("******** Asserting AWS CLOUDWATCH LOG STREAM ********")
	ls_names := getMultiKeyValuesFromData(value, []string{"name", "log_group_name"})

	cw_client := aws.NewCloudWatchLogsClient(a.t, a.AwsRegion)

	for _, element := range ls_names {
		output, err := cw_client.DescribeLogStreams(&cloudwatchlogs.DescribeLogStreamsInput{
			LogGroupName:        aws_sdk.String(element["log_group_name"].(string)),
			LogStreamNamePrefix: aws_sdk.String(element["name"].(string)),
		})
		assert.NoErrorf(a.t, err, "AWS LOG STREAM :- Error Message %v", err)
		assert.Greater(a.t, len(output.LogStreams), 0, "No Log stream found with the name ."+element["name"].(string))
	}
}

func (a *ResourcesAssert) AWS_SERVERLESSAPPLICATIONREPOSITORY_CLOUDFORMATION_STACK(value interface{}) {
	fmt.Println("******** Asserting AWS SERVERLESSAPPLICATIONREPOSITORY CLOUDFORMATION STACK ********")
	cf_arns := getKeyValuesFromData(value, "id")

	mySession := session.Must(session.NewSession())
	svc := cloudformation.New(mySession, aws_sdk.NewConfig().WithRegion(a.AwsRegion))

	for _, element := range cf_arns {
		output, err := svc.DescribeStacks(&cloudformation.DescribeStacksInput{
			StackName: &element,
		})
		assert.NoErrorf(a.t, err, "AWS CLOUDFORMATION STACK :- Error Message %v", err)
		assert.Greater(a.t, len(output.Stacks), 0, "No CloudFormation stack found with the name ."+element)
	}
}

func (a *ResourcesAssert) AWS_KINESIS_FIREHOSE_DELIVERY_STREAM(value interface{}) {
	fmt.Println("******** Asserting AWS KINESIS FIREHOSE DELIVERY STREAM ********")
	stream_arns := getKeyValuesFromData(value, "name")

	mySession := session.Must(session.NewSession())
	svc := firehose.New(mySession, aws_sdk.NewConfig().WithRegion(a.AwsRegion))

	for _, element := range stream_arns {
		_, err := svc.DescribeDeliveryStream(&firehose.DescribeDeliveryStreamInput{
			DeliveryStreamName: &element,
		})
		assert.NoErrorf(a.t, err, "AWS KINESIS FIREHOSE STREAM :- Error Message %v", err)
	}
}
