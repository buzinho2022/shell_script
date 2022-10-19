#!/bin/bash
echo "Set Compose Version"
export COMPOSE_VERSION=v2.11.1
# echo "Login as sudo user"
# sudo -i
echo "Updating Packages..."
if ! sudo yum update -y
then
    echo "Update Failed. Check your repository files in /etc/yum.repos.d/"
    exit 1
fi
echo "Packages updated!"
echo "Installing Docker using convenience script..."
curl -fsSL https://get.docker.com -o get-docker.sh
DRY_RUN=1 sh ./get-docker.sh
if ! sudo sh get-docker.sh
then
    echo "Docker Installation failed. Verify if convenience script is up-to-date."
    exit 1
fi
echo "Docker installation done successfully"
echo "Download and make docker-compose executable"
sudo curl -L "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo "Add $USER to Group docker."
sudo usermod -aG docker $USER
echo "Start Docker Service."
sudo service docker start
echo "Create docker volumes for Streamsets Data Collector container."
if ! sudo docker volume create sdc-data
then
    echo "Docker data volume could not be created."
    exit 1
fi
if ! sudo docker volume create sdc-logs
then
    echo "Docker log volume could not be created."
    exit 1
fi
echo "Docker volumes created."
echo "Login into Container Registry."
if ! sudo docker login -u magdatastrategy -p SVm1Ndyh33mD4CMzrIOu7/sf5IwrDlgw magdatastrategy.azurecr.io
then
    echo "Could not connect in container registry. Check your credentials."
    exit 1
fi
echo "Connected to container registry."
echo "Download Streamsets Data Collector image"
sudo docker image pull magdatastrategy.azurecr.io/data-collector:4.4.0-dev
echo "Create docker-compose file to start SDC service"
# Criando arquivo compose para subir o serviço
cat <<EOF | sudo tee $PWD/docker-compose.yml
version: "3.8"

services:
  sdc:
    deploy:
      mode: replicated
      replicas: 1
      resources:
        limits:
          cpus: '2'
          memory: 63488M
        reservations:
          memory: 63488M
      restart_policy:
        condition: on-failure
        max_attempts: 5
    hostname:
      $HOSTNAME
    environment:
      - SDC_CONF_https_port=18636
    image: magdatastrategy.azurecr.io/data-collector:4.4.0-dev
    extra_hosts:
      - magplataformadecorretoresfunctionhmg.azurewebsites.net:10.253.55.4
      - magdatastrategyeventoscorporativoshmg-brazilsouth.mongo.cosmos.azure.com:10.253.55.12
      - magdatastrategyeventoscorporativoshmg.mongo.cosmos.azure.com:10.253.55.11
      - datastrategyhmg2.servicebus.windows.net:10.253.55.9
      - datastrategyhmg3.servicebus.windows.net:10.253.55.6
      - ContratoDados.servicebus.windows.net:10.251.0.17
      - ContratoDados2.servicebus.windows.net:10.251.0.15
      - ContratoDadosProposta.servicebus.windows.net:10.251.0.19
    volumes:
      # FOLDERS ##
      # Data files, pipelines, etc.
      - sdc-data:/data
      # SDC Log files
      - sdc-logs:/logs 
volumes:
  sdc-data:
    external: true
  sdc-logs:
    external: true
EOF
echo "Creating container for Streamsets Data Collector..."
docker-compose up -d
# echo "Running on IP:"
# ip a s ens192 | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2
# echo "On port 18636."