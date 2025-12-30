# ---------------------------------------------------------------------
# VETRA EVOLUTION - ASYNC COMPUTE
# Arquivo: infra/worker.tf
# Versão: 1.0 (Genesis)
# Descrição: Lambda Worker e mapeamento de eventos (Event Source) do DynamoDB.
# ---------------------------------------------------------------------

# 1. A Função Lambda Worker (O Gênio)
resource "aws_lambda_function" "vetra_worker" {
  function_name = "VetraWorker"
  filename      = data.archive_file.lambda_zip.output_path
  role          = aws_iam_role.vetra_lambda_role.arn
  
  # Aponta para: pasta core -> arquivo worker.py -> função worker_handler
  handler       = "core.worker.worker_handler" 
  
  runtime       = "python3.12" 
  timeout       = 60 # 1 minuto (Tempo de sobra pro GPT-5 pensar)
  memory_size   = 256

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      PROJECT = "VetraEvolution"
      MODE    = "WORKER"
    }
  }
}

# 2. O Gatilho (Conecta o Stream da tabela Contexto -> Worker)
resource "aws_lambda_event_source_mapping" "dynamo_trigger" {
  event_source_arn  = aws_dynamodb_table.vetra_context.stream_arn
  function_name     = aws_lambda_function.vetra_worker.arn
  
  starting_position = "LATEST" # Só pega mensagens novas
  batch_size        = 1        # Processa 1 por vez para garantir ordem (pode aumentar depois)
  
  # Filtro: Só acorda se for um INSERT (nova mensagem)
  filter_criteria {
    filter {
      pattern = jsonencode({
        eventName = ["INSERT"]
      })
    }
  }
}