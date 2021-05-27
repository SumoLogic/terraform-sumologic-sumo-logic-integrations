package common

import (
	"fmt"
)

type AssertAws struct{}

func (assertaws AssertAws) aws_s3_bucket() {
	fmt.Println("************* WOW YOU REACHED HERE **************")
}
