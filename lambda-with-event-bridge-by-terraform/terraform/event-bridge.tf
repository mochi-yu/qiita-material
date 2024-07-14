################## IAMの設定 ##################
resource "aws_iam_role" "event_bridge" {
  name = "role-for-test_lambda-event_bridge"
  assume_role_policy = file("event-bridge-assume-role.json")
}

resource "aws_iam_role_policy" "event_bridge" {
  name = "role_policy-for-test_lambda-event_bridge"
  role = aws_iam_role.event_bridge.name
  policy = data.aws_iam_policy_document.event_bridge.json
}

data "aws_iam_policy_document" "event_bridge" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
    ]

    resources = [
      aws_lambda_function.test_lambda.arn,
    ]
  }
}

################## EventBridgeの本体 ##################
resource "aws_scheduler_schedule" "test_lambda" {
  name       = "test_lambda-event_bridge"

  schedule_expression          = "cron(0/3 * * * ? *)"
  schedule_expression_timezone = "Asia/Tokyo"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.test_lambda.arn
    role_arn = aws_iam_role.event_bridge.arn
  }
}
