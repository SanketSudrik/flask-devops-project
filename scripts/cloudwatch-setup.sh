#!/bin/bash
# ============================================================
# AWS CloudWatch Agent Setup Script
# Sets up CPU + Memory monitoring with alerts via SNS
# Run on EC2 after ec2-setup.sh
# ============================================================

set -e

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
SNS_EMAIL="your-email@example.com"       # <-- Replace with your email
SNS_TOPIC_NAME="flask-app-alerts"
ALARM_PREFIX="flask-devops"

echo "==> [1/4] Installing CloudWatch Agent..."
wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
rm amazon-cloudwatch-agent.deb

echo "==> [2/4] Writing CloudWatch Agent config..."
sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json > /dev/null <<EOF
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "cwagent"
  },
  "metrics": {
    "append_dimensions": {
      "InstanceId": "\${aws:InstanceId}"
    },
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": ["used_percent"],
        "metrics_collection_interval": 60,
        "resources": ["/"]
      },
      "cpu": {
        "measurement": ["cpu_usage_active"],
        "metrics_collection_interval": 60,
        "totalcpu": true
      }
    }
  }
}
EOF

echo "==> [3/4] Starting CloudWatch Agent..."
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s

echo "==> [4/4] Creating SNS Topic and CloudWatch Alarms..."

# Create SNS topic
SNS_ARN=$(aws sns create-topic --name "$SNS_TOPIC_NAME" --region "$REGION" --query 'TopicArn' --output text)
echo "SNS Topic ARN: $SNS_ARN"

# Subscribe email
aws sns subscribe \
  --topic-arn "$SNS_ARN" \
  --protocol email \
  --notification-endpoint "$SNS_EMAIL" \
  --region "$REGION"

echo "Check your email ($SNS_EMAIL) to confirm the SNS subscription!"

# CPU High Alarm
aws cloudwatch put-metric-alarm \
  --alarm-name "${ALARM_PREFIX}-cpu-high" \
  --alarm-description "CPU usage exceeded 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=InstanceId,Value="$INSTANCE_ID" \
  --evaluation-periods 2 \
  --alarm-actions "$SNS_ARN" \
  --region "$REGION"

# Memory High Alarm (requires CloudWatch Agent)
aws cloudwatch put-metric-alarm \
  --alarm-name "${ALARM_PREFIX}-memory-high" \
  --alarm-description "Memory usage exceeded 85%" \
  --metric-name mem_used_percent \
  --namespace CWAgent \
  --statistic Average \
  --period 300 \
  --threshold 85 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=InstanceId,Value="$INSTANCE_ID" \
  --evaluation-periods 2 \
  --alarm-actions "$SNS_ARN" \
  --region "$REGION"

# Disk Usage Alarm
aws cloudwatch put-metric-alarm \
  --alarm-name "${ALARM_PREFIX}-disk-high" \
  --alarm-description "Disk usage exceeded 80%" \
  --metric-name disk_used_percent \
  --namespace CWAgent \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=InstanceId,Value="$INSTANCE_ID" \
  --evaluation-periods 1 \
  --alarm-actions "$SNS_ARN" \
  --region "$REGION"

echo ""
echo "=============================="
echo " CloudWatch Setup Complete!"
echo " Alarms: CPU > 80%, Memory > 85%, Disk > 80%"
echo " Alerts sent to: $SNS_EMAIL"
echo "=============================="
