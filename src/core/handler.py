# ---------------------------------------------------------------------
# VETRA EVOLUTION - CORE LOGIC
# Arquivo: src/core/handler.py
# Versão: 1.0 (Genesis)
# Autor: Vetra System
# Descrição: Dispatcher síncrono. Recebe Webhook, normaliza e salva no DB.
# ---------------------------------------------------------------------

import json
import logging
import os
import time
import boto3
import uuid

# Configuração de Logs
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Conexão com DynamoDB (Otimização: feita fora do handler para reutilizar conexão)
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = 'VetraEvolution_Contexto'
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    """
    Dispatcher: Recebe -> Padroniza -> Salva no DB -> Retorna 200 OK
    """
    try:
        # 1. Parsing do Body
        body = {}
        if 'body' in event:
            if isinstance(event['body'], str):
                body = json.loads(event['body'])
            else:
                body = event['body']
        
        logger.info(f"PAYLOAD RECEBIDO: {json.dumps(body)}")

        # 2. Identificação da Plataforma (Roteador Simples)
        platform = "unknown"
        user_id = "unknown"
        user_name = "unknown"
        message_text = ""
        chat_id = ""

        # Lógica de detecção do TELEGRAM
        if 'update_id' in body and 'message' in body:
            platform = "telegram"
            msg = body['message']
            
            # Extração segura de dados
            user_id = str(msg.get('from', {}).get('id', 'unknown'))
            user_name = msg.get('from', {}).get('first_name', 'User')
            chat_id = str(msg.get('chat', {}).get('id', ''))
            message_text = msg.get('text', '')

            # Ignorar mensagens sem texto (ex: edição, sticker sem legenda)
            if not message_text:
                return {"statusCode": 200, "body": "Ignored: No text"}

        # --- AQUI É O PULO DO GATO (O Início do Soft-Code) ---
        # Salvamos no DynamoDB. Isso vai DISPARAR o Worker via Stream.
        if platform != "unknown":
            item = {
                'SessionID': f"{platform}#{user_id}", # PK: Ex: telegram#12345
                'Timestamp': int(time.time() * 1000), # SK: Milissegundos para precisão
                'ExpireAt': int(time.time()) + (86400 * 7), # TTL: Apaga em 7 dias automático
                
                # Metadados para o Worker processar depois
                'Platform': platform,
                'ChatID': chat_id,
                'UserName': user_name,
                'UserMessage': message_text,
                'Status': 'PENDING', # O Worker vai procurar por isso
                'Direction': 'INCOMING' # Mensagem entrando
            }
            
            table.put_item(Item=item)
            logger.info(f"MENSAGEM SALVA NO DYNAMO: {item['SessionID']}")

        return {
            "statusCode": 200,
            "body": json.dumps({"status": "queued"})
        }

    except Exception as e:
        logger.error(f"ERRO CRÍTICO NO HANDLER: {str(e)}")
        # Mesmo com erro, retornamos 200 pro Telegram não ficar tentando reenviar infinitamente
        return {
            "statusCode": 200,
            "body": json.dumps({"error": "internal_error"})
        }