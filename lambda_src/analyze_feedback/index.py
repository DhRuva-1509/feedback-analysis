import json
import boto3
import os
import time
import logging
from botocore.exceptions import ClientError

s3 = boto3.client("s3")
comprehend = boto3.client("comprehend")
cloudwatch = boto3.client("cloudwatch")
sns = boto3.client("sns")

logger = logging.getLogger()
logger.setLevel(logging.INFO)

MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")
REGION = os.environ.get("AWS_REGION", "ca-central-1")

def handler(event, context):
    logger.info("Event received: %s", json.dumps(event))

    try:
        bucket = event["Records"][0]["s3"]["bucket"]["name"]
        key = event["Records"][0]["s3"]["object"]["key"]
    except Exception as e:
        logger.error("Failed to parse event: %s", str(e))
        send_sns_alert("Invalid event format")
        return {"statusCode": 400, "body": "Invalid event format"}

    try:
        head = s3.head_object(Bucket=bucket, Key=key)
        size = head["ContentLength"]
        if size > MAX_FILE_SIZE:
            raise Exception(f"File too large: {size} bytes")
    except Exception as e:
        logger.error("File too large or missing: %s", str(e))
        send_sns_alert(f"S3 file too large or missing: {key}")
        return {"statusCode": 400, "body": "File too large"}

    try:
        obj = s3.get_object(Bucket=bucket, Key=key)
        text = obj["Body"].read().decode("utf-8")
    except Exception as e:
        logger.error("Failed to read file: %s", str(e))
        send_sns_alert(f"Failed to read file: {key}")
        return {"statusCode": 500, "body": "Error reading file"}

    try:
        sentiment, key_phrases = comprehend_with_retry(text)
    except Exception as e:
        return {"statusCode": 500, "body": "Comprehend analysis failed"}

    result = {
        "file": key,
        "sentiment": sentiment,
        "key_phrases": key_phrases
    }

    result_bytes = json.dumps(result).encode("utf-8")
    if len(result_bytes) > MAX_FILE_SIZE:
        msg = "Comprehend result exceeds 5MB"
        logger.error(msg)
        send_sns_alert(msg)
        return {"statusCode": 400, "body": msg}

    result_key = key.replace("incoming/", "processed/").replace(".txt", "_result.json")
    try:
        s3.put_object(
            Bucket=bucket,
            Key=result_key,
            Body=json.dumps(result),
            ContentType="application/json"
        )
    except Exception as e:
        logger.error("Failed to upload result: %s", str(e))
        send_sns_alert("Failed to upload result to S3")
        return {"statusCode": 500, "body": "Upload error"}

    # CloudWatch custom metric
    try:
        cloudwatch.put_metric_data(
            Namespace="FeedbackAnalysis",
            MetricData=[
                {
                    "MetricName": "ProcessedFeedbackCount",
                    "Dimensions": [{"Name": "Function", "Value": "analyze_feedback"}],
                    "Value": 1,
                    "Unit": "Count"
                }
            ]
        )
    except Exception as e:
        logger.warning("Failed to push CloudWatch metric: %s", str(e))

    logger.info("Successfully analyzed and stored results.")
    return {
        "statusCode": 200,
        "body": f"Analysis complete. Output saved to {result_key}"
    }

def comprehend_with_retry(text, retries=3, delay=1.0):
    for attempt in range(1, retries + 1):
        try:
            sentiment_resp = comprehend.detect_sentiment(Text=text, LanguageCode="en")
            key_phrases_resp = comprehend.detect_key_phrases(Text=text, LanguageCode="en")
            return sentiment_resp, key_phrases_resp["KeyPhrases"]
        except ClientError as e:
            code = e.response["Error"]["Code"]
            if code in ("ThrottlingException", "TooManyRequestsException"):
                logger.warning("Throttled (attempt %d). Retrying in %.1f seconds...", attempt, delay)
                time.sleep(delay)
                delay *= 2
            else:
                logger.error("ClientError: %s", str(e))
                send_sns_alert("Comprehend API error: " + str(e))
                raise e
        except Exception as e:
            logger.error("Unhandled exception: %s", str(e))
            send_sns_alert("Unexpected Comprehend error")
            raise e
    raise Exception("Comprehend retry limit exceeded")

def send_sns_alert(message):
    if not SNS_TOPIC_ARN:
        logger.warning("SNS_TOPIC_ARN not set. Cannot send alert.")
        return
    try:
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="Analyze Feedback Lambda Error",
            Message=message
        )
    except ClientError as e:
        logger.error("Failed to publish to SNS: %s", str(e))
