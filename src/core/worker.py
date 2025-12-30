import json
import logging
import boto3
from boto3.dynamodb.types import TypeDeserializer

# --- CONFIGURAÇÃO DA INFRAESTRUTURA ---
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Ferramenta de Limpeza (Tradutor Técnico: DynamoDB JSON -> Python Dict)
deserializer = TypeDeserializer()

def unmarshall_dynamo_json(dynamo_json):
    """
    Função de Infraestrutura:
    Remove a formatação técnica do DynamoDB ({'S': 'Valor'}) 
    e entrega o dado limpo para o sistema ('Valor').
    """
    return {k: deserializer.deserialize(v) for k, v in dynamo_json.items()}

def worker_handler(event, context):
    """
    Worker Estrutural: 
    1. Recebe o evento do Stream.
    2. Limpa o JSON técnico.
    3. Disponibiliza o dado limpo para uso futuro.
    """
    try:
        for record in event['Records']:
            # Apenas processa inserções de novos dados
            if record['eventName'] == 'INSERT':
                
                # 1. A LIMPEZA (O passo estrutural vital)
                raw_data = record['dynamodb']['NewImage']
                clean_data = unmarshall_dynamo_json(raw_data)
                
                # 2. Confirmação de Integridade
                # Aqui o sistema prova que entendeu o dado, sem agir sobre ele.
                logger.info(f"DADO LIMPO E ESTRUTURADO: {json.dumps(clean_data)}")

                # --- PONTO DE EXTENSÃO FUTURA ---
                # O ambiente está pronto. Quando você criar as configurações de IA
                # no banco, a lógica de leitura será inserida aqui.
                # --------------------------------

    except Exception as e:
        logger.error(f"ERRO ESTRUTURAL NO WORKER: {str(e)}")
        # Não damos 'raise' aqui para não travar o stream em caso de lixo de dados,
        # apenas logamos o erro estrutural.
        return {"status": "error", "message": str(e)}