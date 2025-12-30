# ---------------------------------------------------------------------
# VETRA EVOLUTION - DATA LAYER
# Arquivo: infra/dynamo.tf
# Versão: 1.0 (Genesis)
# Descrição: Definição das tabelas Mestra (Core) e Memória (Contexto) com Streams.
# ---------------------------------------------------------------------

resource "aws_dynamodb_table" "vetra_core" {
  name         = "VetraEvolution"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  range_key    = "SK"

  # --- NOVO: Habilitando o Stream ---
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES" 
  # NEW_AND_OLD_IMAGES = A Lambda receberá o dado como era antes E como ficou depois.
  # ----------------------------------

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  tags = {
    Project = "VetraEvolution"
    Module  = "Core"
  }
}

resource "aws_dynamodb_table" "vetra_context" {
  name         = "VetraEvolution_Contexto"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "SessionID" 
  range_key    = "Timestamp"

  # --- NOVO: Habilitando o Stream ---
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE" 
  # NEW_IMAGE = Só precisamos ver a mensagem nova que chegou.
  # ----------------------------------

  attribute {
    name = "SessionID"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "N"
  }

  ttl {
    attribute_name = "ExpireAt"
    enabled        = true
  }

  tags = {
    Project = "VetraEvolution"
    Module  = "Memory"
  }
}