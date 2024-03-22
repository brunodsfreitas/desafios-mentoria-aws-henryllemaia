#!/bin/bash
SECRET_NAME="nome_do_seu_secreto"
FILE_PATH="caminho_para_o_seu_arquivo"
SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query SecretString --output text)
openssl enc -aes-256-cbc -salt -in "$FILE_PATH" -out "$FILE_PATH.enc" -k "$SECRET_VALUE"

##################

SECRET_NAME="nome_do_seu_secreto"
ENCRYPTED_FILE_PATH="caminho_para_o_seu_arquivo.enc"
SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query SecretString --output text)
openssl enc -aes-256-cbc -d -in "$ENCRYPTED_FILE_PATH" -out "${ENCRYPTED_FILE_PATH%.enc}" -k "$SECRET_VALUE"
