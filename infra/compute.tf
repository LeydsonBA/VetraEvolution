# infra/compute.tf

# --- 1. PREPARAÇÃO DO CÓDIGO (ZIP) ---
# O Terraform vai zipar sua pasta 'src' automaticamente
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../src"        # Pega tudo dentro de src
  output_path = "vetra_code.zip"
}

# --- 2. A FUNÇÃO LAMBDA ---
resource "aws_lambda_function" "vetra_handler" {
  function_name = "VetraHandler"
  filename      = data.archive_file.lambda_zip.output_path
  role          = aws_iam_role.vetra_lambda_role.arn
  
  # Aponta para: pasta core -> arquivo handler.py -> função lambda_handler
  handler       = "core.handler.lambda_handler" 
  
  # Usaremos Python 3.12 (versão estável gerenciada pela AWS)
  runtime       = "python3.12" 
  timeout       = 30 # Segundos (GPT-5 pode demorar um pouco)
  memory_size   = 256

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      PROJECT = "VetraEvolution"
    }
  }
}

# --- 3. O API GATEWAY (HTTP API) ---
resource "aws_apigatewayv2_api" "vetra_api" {
  name          = "VetraGateway"
  protocol_type = "HTTP"
}

# Estágio padrão (Auto-deploy)
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.vetra_api.id
  name        = "$default"
  auto_deploy = true
}

# Integração: Conecta o Gateway ao Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.vetra_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.vetra_handler.invoke_arn
}

# Rota: Captura TUDO (POST, GET) e manda pro Lambda
resource "aws_apigatewayv2_route" "any_route" {
  api_id    = aws_apigatewayv2_api.vetra_api.id
  route_key = "POST /webhook" # Define que ouviremos em /webhook
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Permissão: Deixa o API Gateway invocar o Lambda
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.vetra_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.vetra_api.execution_arn}/*/*"
}

# --- 4. OUTPUT (Para sabermos a URL) ---
output "webhook_url" {
  value = "${aws_apigatewayv2_api.vetra_api.api_endpoint}/webhook"
}