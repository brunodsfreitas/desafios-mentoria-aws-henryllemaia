#!/bin/bash
if command -v curl &> /dev/null && command -v jq &> /dev/null; then
    if [ "$#" -eq 2 ]; then
        ip_range=$(curl -s https://ip-ranges.amazonaws.com/ip-ranges.json | jq -r '.prefixes[] | select(.region=="'$1'") | select(.service=="'$2'") | .ip_prefix')
        echo "$ip_range" | jq -nR '[inputs | {(.): .}] | add'
        exit 0
    else
        echo "Para usar esse script, você deve informar 2 parâmetros, região da aws e o serviço. Exemplo: script.sh us-east-2 EC2_INSTANCE_CONNECT"
        exit 1
    fi
else
    echo "Comandos necessários não disponíveis: curl, jq. Necessário a instalação."
    exit 1
fi