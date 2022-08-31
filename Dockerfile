FROM streamsets/datacollector:4.4.0

# Labels
LABEL maintainer="triscal.lsiqueira@terceiros.mag.com.br"
LABEL team="Data Strategy"

# Explicitamente utilizar o horário do Brasil
#ENV TZ=America/Sao_Paulo

# Arquivos de configurações alterados
COPY credential-stores.properties /etc/sdc/credential-stores.properties
COPY sdc-env.sh /opt/streamsets-datacollector-4.4.0/libexec/sdc-env.sh
COPY sdc-log4j.properties /etc/sdc/sdc-log4j.properties
COPY sdc.properties /etc/sdc/sdc.properties
# Pastas com bibliotecas para a aplicação funcionar com o que temos hoje
COPY streamsets-libs /opt/streamsets-datacollector-4.4.0/streamsets-libs
COPY streamsets-libs-extras /opt/streamsets-datacollector-4.4.0/streamsets-libs-extras
COPY telegraf-1.20.4-r2.apk /root
RUN sudo apk update
WORKDIR /root 
RUN sudo apk add --allow-untrusted telegraf-1.20.4-r2.apk
# Copiar arquivos de conf e var de ambiente
COPY telegraf.conf /etc/telegraf
COPY telegraf /etc/default
RUN sudo apk add openrc --no-cache
