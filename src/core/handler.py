import json
import logging
import os

# Configuração de Logs (Nativo da AWS)
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Bootstrap Handler: O ponto único de entrada.
    """
    try:
        # 1. Log do evento bruto (para debug no CloudWatch)
        logger.info(f"EVENTO RECEBIDO: {json.dumps(event)}")

        # 2. Parsing do Body (O API Gateway pode enviar como string)
        body = {}
        if 'body' in event:
            if isinstance(event['body'], str):
                body = json.loads(event['body'])
            else:
                body = event['body']
        
        # 3. Resposta Padrão (Por enquanto)
        # Futuramente aqui entrará o Roteador (Telegram vs Discord)
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "message": "Vetra Evolution: Conexão Estabelecida",
                "system_status": "ONLINE",
                "received_data": body
            })
        }

    except Exception as e:
        logger.error(f"ERRO CRÍTICO: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Internal Server Error"})
        }