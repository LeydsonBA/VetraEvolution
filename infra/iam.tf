# ---------------------------------------------------------------------
# VETRA EVOLUTION - SECURITY LAYER
# Arquivo: infra/iam.tf
# Versão: 1.0 (Genesis)
# Descrição: Roles e Políticas de permissão (Least Privilege) para Lambdas.
# ---------------------------------------------------------------------

resource "aws_iam_role" "vetra_lambda_role" {
  name = "VetraLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.vetra_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "dynamo_access" {
  name = "VetraDynamoAccess"
  role = aws_iam_role.vetra_lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:UpdateItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:DescribeStream",
        "dynamodb:GetRecords",
        "dynamodb:GetShardIterator",
        "dynamodb:ListStreams"
      ]
      Resource = "arn:aws:dynamodb:*:*:table/Vetra*"
    }]
  })
}