package storage

import (
	"fmt"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

type R2 struct {
	Client    *s3.Client
	Presigner *s3.PresignClient
	Bucket    string
}

func NewR2(
	accountID string,
	accessKey string,
	secretKey string,
	bucket string,
) *R2 {

	endpoint := fmt.Sprintf(
		"https://%s.r2.cloudflarestorage.com",
		accountID,
	)

	client := s3.New(s3.Options{
		Region: "auto",

		BaseEndpoint: aws.String(endpoint),

		Credentials: credentials.NewStaticCredentialsProvider(
			accessKey,
			secretKey,
			"",
		),
	})

	return &R2{
		Client:    client,
		Presigner: s3.NewPresignClient(client),
		Bucket:    bucket,
	}
}
