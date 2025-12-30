import json
import os
import re

import boto3
from botocore.exceptions import ClientError

ses = boto3.client("ses")

EMAIL_PATTERN = re.compile(r"^[^\s@]+@[^\s@]+\.[^\s@]+$")


def handler(event, context):
    # Handle CORS preflight
    if event.get("requestContext", {}).get("http", {}).get("method") == "OPTIONS":
        return {"statusCode": 200, "headers": cors_headers(), "body": ""}

    try:
        body = json.loads(event.get("body", "{}"))
        name = body.get("name", "").strip()
        email = body.get("email", "").strip()
        message = body.get("message", "").strip()

        if not all([name, email, message]):
            return error_response(400, "Missing required fields")

        if not EMAIL_PATTERN.match(email):
            return error_response(400, "Invalid email format")

        send_email(name, email, message)

        return {"statusCode": 200, "headers": cors_headers(), "body": json.dumps({"success": True})}

    except ValueError as e:
        print(f"Configuration error: {e}")
        return error_response(500, "Server configuration error")
    except ClientError as e:
        print(f"SES error: {e}")
        return error_response(500, "Failed to send email")
    except Exception as e:
        print(f"Error: {e}")
        return error_response(500, "Internal server error")


def send_email(name: str, email: str, message: str):
    to_email = os.environ.get("TO_EMAIL")
    from_email = os.environ.get("FROM_EMAIL")

    if not to_email or not from_email:
        raise ValueError("TO_EMAIL and FROM_EMAIL environment variables must be set")

    ses.send_email(
        Source=from_email,
        Destination={"ToAddresses": [to_email]},
        Message={
            "Subject": {"Data": f"Contact Form: {name}"},
            "Body": {"Text": {"Data": f"Name: {name}\nEmail: {email}\n\nMessage:\n{message}"}},
        },
        ReplyToAddresses=[email],
    )


def cors_headers():
    return {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
        "Content-Type": "application/json",
    }


def error_response(status: int, message: str):
    return {"statusCode": status, "headers": cors_headers(), "body": json.dumps({"error": message})}
