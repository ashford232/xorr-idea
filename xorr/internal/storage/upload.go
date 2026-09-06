package storage

import (
	"context"
	"fmt"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func (r *R2) CreateUploadURL(
	ctx context.Context,
	key string,
	contentType string,
) (string, error) {

	request, err := r.Presigner.PresignPutObject(
		ctx,
		&s3.PutObjectInput{
			Bucket:      aws.String(r.Bucket),
			Key:         aws.String(key),
			ContentType: aws.String(contentType),
		},
		s3.WithPresignExpires(10*time.Minute),
	)

	if err != nil {
		return "", fmt.Errorf("failed to create upload URL: %w", err)
	}

	return request.URL, nil
}