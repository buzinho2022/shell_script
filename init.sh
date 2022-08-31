#!/bin/bash

# author: Rodrigo Mota / Luiz Felipe
# date: 2019-05-31
# deployment script StreamSets

if [ $# -lt 5 ]; then
   echo "Obrigatório uso de 4 argumentos: <Porta> <Host> <Image> <ArqTelegraf> <Memoria>"
   echo "Como usar: $0 <Porta> <Host> <Image> <ArqTelegraf>"
   echo "Exemplo: ./init.sh 8080:8080 sdc_dev_host imagem_docker var_telegraf 1024"
   exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

SERVER_PORT="$1"
SERVER_NOME="$2"
SERVER_IMG="$3"
SERVER_VARFILE_TELEGRAF="$4"
SERVER_MEMORY="$5"

# Montando o comando de execução do container, envio do arquivo de varial para o dir /etc/default/telegraf
# O comando de execução do container é executado com o comando docker run -d -p <porta> <nome> <image>
# O arquivo de variavel é enviado para o diretorio /etc/default/telegraf, para que o telegraf possa ser iniciado
docker run -d -p "${SERVER_PORT}" --name="${SERVER_NOME}" imagem:"${SERVER_IMG}" \ 
    -v ${SCRIPT_DIR}/${SERVER_VARFILE_TELEGRAF}:/etc/default/telegraf \
    -v ${SCRIPT_DIR}/telegraf.conf:/etc/telegraf/telegraf.conf \
    -env VAR_MEMORY=$SERVER_MEMORY