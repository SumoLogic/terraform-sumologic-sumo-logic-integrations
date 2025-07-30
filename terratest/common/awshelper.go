package common

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
    "context"
	aws_sdk "github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	elbv2 "github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2"
	elbv2types "github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2/types"
	ec2types "github.com/aws/aws-sdk-go-v2/service/ec2/types"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/stretchr/testify/assert"
)

// createELB will create the Load Balancer, target group, modify the security group for your IP.
// This will also add cleanup for ELB and other resources.
func (a *ResourcesAssert) CreateELB(LoadBalancerName, TargetGroupName string) (*string, *string) {
	var lb_id *string
	var dns_name *string

	// Load default config with region
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion(a.AwsRegion))
	if err != nil {
		assert.NoErrorf(a.t, err, "Failed to load AWS config")
		return nil, nil
	}

	svc := elbv2.NewFromConfig(cfg)

	subnets, vpc_id := a.GetSubnetsIdsFromFirstVPC()
	group_id := a.GetSecurityGroupFromVPC(vpc_id, aws_sdk.String("default"))
	ip_address := a.GetMyIpAddress()
	if vpc_id != nil && group_id != nil {

		a.ModifySGInboundRules(group_id, ip_address)

		loadOutput, error := svc.CreateLoadBalancer(context.TODO(), &elbv2.CreateLoadBalancerInput{
			Name:           aws_sdk.String(LoadBalancerName),
			Type:           elbv2types.LoadBalancerTypeEnumApplication,
			Scheme:         elbv2types.LoadBalancerSchemeEnumInternetFacing,
			SecurityGroups: []string{*group_id},
			Subnets:        subnets,
		})
		if assert.NoError(a.t, error, "Error occured while creating load balancer") {
			lb_id = loadOutput.LoadBalancers[0].LoadBalancerArn
			dns_name = loadOutput.LoadBalancers[0].DNSName
			fmt.Println("** Load Balancer created with ARN as " + *lb_id)
			a.t.Cleanup(func() {
				svc.DeleteLoadBalancer(context.TODO(), &elbv2.DeleteLoadBalancerInput{LoadBalancerArn: lb_id})
				fmt.Println("** Load Balancer deleted with ARN as " + *lb_id)
			})
			tgOutput, error := svc.CreateTargetGroup(context.TODO(), &elbv2.CreateTargetGroupInput{
				Name:            aws_sdk.String(TargetGroupName),
				Protocol:        elbv2types.ProtocolEnumHttp,
				Port:            aws_sdk.Int32(80),
				TargetType:      elbv2types.TargetTypeEnumInstance,
				ProtocolVersion: aws_sdk.String("HTTP1"),
				VpcId:           vpc_id,
			})
			if assert.NoError(a.t, error, "Error occured while creating Target group") {
				tg_id := tgOutput.TargetGroups[0].TargetGroupArn
				fmt.Println("** Target Group created with ARN as " + *tg_id)
				a.t.Cleanup(func() {
					svc.DeleteTargetGroup(context.TODO(), &elbv2.DeleteTargetGroupInput{TargetGroupArn: tg_id})
					fmt.Println("** Target Group deleted with ARN as " + *tg_id)
				})
				listenerOutput, error := svc.CreateListener(context.TODO(), &elbv2.CreateListenerInput{
					LoadBalancerArn: lb_id,
					Protocol:        elbv2types.ProtocolEnumHttp,
					Port:            aws_sdk.Int32(80),
					DefaultActions:  []elbv2types.Action{
						{Type: elbv2types.ActionTypeEnumForward, TargetGroupArn: tg_id},
					},
				})
				if assert.NoError(a.t, error, "Error occured while creating Listener") {
					fmt.Println("** Listener created with ARN as " + *listenerOutput.Listeners[0].ListenerArn)
					a.t.Cleanup(func() {
						svc.DeleteListener(context.TODO(), &elbv2.DeleteListenerInput{ListenerArn: listenerOutput.Listeners[0].ListenerArn})
						fmt.Println("** Listener deleted with ARN as " + *listenerOutput.Listeners[0].ListenerArn)
					})
				}
			}
		}
	}
	return lb_id, dns_name
}

func (a *ResourcesAssert) GetSubnetsIdsFromFirstVPC() ([]string, *string) {
	var subnets_list []string
	var vpc_id *string
	ec2Client := aws.NewEc2Client(a.t, a.AwsRegion)
	sn_all, error := ec2Client.DescribeSubnets(context.TODO(), &ec2.DescribeSubnetsInput{})
	if assert.NoError(a.t, error, "Error occured while fetching Subnets.") && len(sn_all.Subnets) > 0 {
		vpc_id = sn_all.Subnets[0].VpcId
		for _, element := range sn_all.Subnets {
			if strings.Compare(*element.VpcId, *vpc_id) == 0 {
				subnets_list = append(subnets_list, aws_sdk.ToString(element.SubnetId))
			}
		}
	}
	return subnets_list, vpc_id
}

func (a *ResourcesAssert) GetSecurityGroupFromVPC(vpcId, group_name *string) *string {
	var group_id *string
	if vpcId != nil && group_name != nil {
		ec2Client := aws.NewEc2Client(a.t, a.AwsRegion)
		input := ec2.DescribeSecurityGroupsInput{Filters: []ec2types.Filter{
			{Name: aws_sdk.String("group-name"), Values: []string{aws_sdk.ToString(group_name)}},
			{Name: aws_sdk.String("vpc-id"), Values: []string{aws_sdk.ToString(vpcId)}},
		}}
		groups, error := ec2Client.DescribeSecurityGroups(context.TODO(), &input)
		if assert.NoError(a.t, error, "Error occured while fetching security group.") && len(groups.SecurityGroups) > 0 {
			group_id = groups.SecurityGroups[0].GroupId
		}
	}
	return group_id
}

func (a *ResourcesAssert) ModifySGInboundRules(GroupId *string, IpAddress string) {
	if GroupId != nil {
		ec2Client := aws.NewEc2Client(a.t, a.AwsRegion)
		ec2Client.AuthorizeSecurityGroupIngress(context.TODO(), &ec2.AuthorizeSecurityGroupIngressInput{
			GroupId:    GroupId,
			IpProtocol: aws_sdk.String("-1"),
			CidrIp:     aws_sdk.String(fmt.Sprintf("%v/32", IpAddress)),
		})
		fmt.Println("***** Security group Ingress modified.")
		a.t.Cleanup(func() {
			ec2Client.RevokeSecurityGroupIngress(context.TODO(), &ec2.RevokeSecurityGroupIngressInput{
				GroupId:    GroupId,
				IpProtocol: aws_sdk.String("-1"),
				CidrIp:     aws_sdk.String(fmt.Sprintf("%v/32", IpAddress)),
			})
			fmt.Println("***** Security group Ingress reverted.")
		})
	}
}

func (a *ResourcesAssert) GetMyIpAddress() string {
	url := "https://api.ipify.org?format=text"
	fmt.Printf("Getting IP address from  ipify ...\n")
	resp, err := http.Get(url)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()
	ip, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}
	return string(ip)
}

func (a *ResourcesAssert) ValidateLoadBalancerAccessLogs(lb_id *string, bucketName string) {

	// Load default config with region
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion(a.AwsRegion))
	if err != nil {
		assert.NoErrorf(a.t, err, "Failed to load AWS config")
		return
	}

	svc := elbv2.NewFromConfig(cfg)

	output, error := svc.DescribeLoadBalancerAttributes(context.TODO(), &elbv2.DescribeLoadBalancerAttributesInput{
		LoadBalancerArn: lb_id,
	})
	if assert.NoError(a.t, error, "Error while fetching load balancer details") {
		for _, element := range output.Attributes {
			if strings.Compare("access_logs.s3.enabled", *element.Key) == 0 {
				assert.Equal(a.t, aws_sdk.String("true"), element.Value, "Access Logs is not enabled")
			}
			if strings.Compare("access_logs.s3.bucket", *element.Key) == 0 {
				assert.Equal(a.t, &bucketName, element.Value, "Access Logs bucket does not match.")
			}
		}
	}
}
