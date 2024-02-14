INSTANCE_ID_PORTEIRO=i-009d3b6bac4e0872a
IP_PORTEIRO=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID_PORTEIRO --query "Reservations[].Instances[].PublicIpAddress" --profile cliente-porteiro --region us-east-2 --output json | grep -vE '\[|\]' | awk -F'"' '{ print $2 }')
#echo $IP_PORTEIRO
PEM_PATH="/home/brunodsfreitas/Downloads/lab-aws-2024-porteiro.pem"
SERVIDOR_RDS_1=lab-aws-2024-rds-3-tunnel.c6uxh1t95jvm.us-east-2.rds.amazonaws.com
PORTA_LOCAL_RDS_1=5439
ssh -f -N -i $PEM_PATH ec2-user@$IP_PORTEIRO -L $PORTA_LOCAL_RDS_1:$SERVIDOR_RDS_1:5432
echo "Tunnel estabelecido:"
echo "> $SERVIDOR_RDS_1 no endereço *127.0.0.1:$PORTA_LOCAL_RDS_1"