#!/bin/bash
#SECRET_NAME="nome_do_seu_secreto"
#FILE_PATH="caminho_para_o_seu_arquivo"
#SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query SecretString --output text)
#openssl enc -aes-256-cbc -salt -in "$FILE_PATH" -out "$FILE_PATH.enc" -k "$SECRET_VALUE"

##################

#SECRET_NAME="nome_do_seu_secreto"
#ENCRYPTED_FILE_PATH="caminho_para_o_seu_arquivo.enc"
#SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query SecretString --output text)
#openssl enc -aes-256-cbc -d -in "$ENCRYPTED_FILE_PATH" -out "${ENCRYPTED_FILE_PATH%.enc}" -k "$SECRET_VALUE"


#!/bin/bash
if ! [ $# -ne 2 ]; then
    if [ $1 = "enc" ]; then
        if [ ! -f "env/site-prod/site-prod.enc" ]; then
            echo "arquivo nao existe prod"
        else
            openssl enc -aes-256-cbc -salt -in env/site-prod/site-prod.tfvars -out env/site-prod/site-prod.enc -k "$2" -pbkdf2 -iter 10000
        fi

        if [ ! -f "env/site-bkp/site-backup.enc" ]; then
            echo "arquivo nao existe bkp"
        else
            openssl enc -aes-256-cbc -salt -in env/site-bkp/site-backup.tfvars -out env/site-bkp/site-backup.enc -k "$2" -pbkdf2 -iter 10000
        fi
    elif [ $1 = "dec" ]; then
        if [ ! -f "env/site-prod/site-prod.enc" ]; then
            echo "arquivo nao existe prod"
        else
            openssl enc -aes-256-cbc -d -in env/site-prod/site-prod.enc -out env/site-prod/site-prod.tfvars -k "$2" -pbkdf2 -iter 10000
        fi

        if [ ! -f "env/site-bkp/site-backup.enc" ]; then
            echo "arquivo nao existe bkp"
        else
            openssl enc -aes-256-cbc -d -in env/site-bkp/site-backup.enc -out env/site-bkp/site-backup.tfvars -k "$2" -pbkdf2 -iter 10000
        fi
    else 
        exit 0
    fi
    
else
    echo "Opções: 'enc' ou 'dec' + chave"
fi