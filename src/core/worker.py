import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def worker_handler(event, context):
    """
    Worker AI: Acionado pelo DynamoDB Stream.
    Processa a lógica pesada (GPT-5, Llama, etc) de forma assíncrona.
    """
    try:
        logger.info(f"WORKER ACORDADO! Eventos a processar: {len(event['Records'])}")

        for record in event['Records']:
            # Só nos interessa quando algo NOVO é inserido (INSERT)
            if record['eventName'] == 'INSERT':
                
                # O DynamoDB envia os dados em um formato estranho chamado 'Marshalled JSON'
                # Ex: {'S': 'Ola Vetra'} ao invés de 'Ola Vetra'
                new_image = record['dynamodb']['NewImage']
                
                logger.info(f"PROCESSANDO MENSAGEM: {json.dumps(new_image)}")
                
                # --- AQUI ENTRARÁ A LÓGICA DO GPT-5 FUTURAMENTE ---
                # 1. Identificar Cliente
                # 2. Carregar Contexto
                # 3. Chamar API OpenAI
                # 4. Enviar Resposta de volta ao Telegram/Discord
                # --------------------------------------------------
                
                logger.info("IA PROCESSADA COM SUCESSO (Simulação)")

    except Exception as e:
        logger.error(f"ERRO NO WORKER: {str(e)}")
        # Em produção, jogaríamos isso para uma fila de 'Dead Letter' (DLQ)
        raise e