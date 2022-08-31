#!/bin/bash

# author: Rodrigo Mota / Luiz Felipe 
# date: 2019-05-31
# Atualização do pacote
# Variaveis a enviar
# urls = ["DOCKER_INFLUX_URL"]
# Token for authentication. Variavel a ser passada --env INFLUX_TOKEN=<your_api_key
# token = "$DOCKER_INFLUX_TOKEN"
# Organization is the name of the organization you wish to write to; must exist.
# organization = "$DOCKER_INFLUXDB_ORG"
# Enviar arquivo para /etc/default/telegraf -> esse aqruivo deve ser executado antes do telegraf contem as variaveis
# de ambiente

sudo yum -y update

# Adicionando repositório do telegraf
cat <<EOF | sudo tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL 
baseurl = https://repos.influxdata.com/rhel/7/x86_64/stable/
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF
# instalando o telegraf
sudo yum -y install telegraf

# configurando o telegraf inicializando o serviço
sudo systemctl enable --now telegraf
