# Use the Azure CLI as the base image
FROM mcr.microsoft.com/azure-cli as base

RUN apk update
RUN apk upgrade
RUN apk add --no-cache unixodbc-dev g++ bash sudo

#Download the desired package(s)
RUN curl -O https://download.microsoft.com/download/1/f/f/1fffb537-26ab-4947-a46a-7a45c27f6f77/msodbcsql18_18.2.1.1-1_amd64.apk \ 
    && curl -O https://download.microsoft.com/download/1/f/f/1fffb537-26ab-4947-a46a-7a45c27f6f77/mssql-tools18_18.2.1.1-1_amd64.apk

#Install the package(s)
RUN sudo apk add --allow-untrusted msodbcsql18_18.2.1.1-1_amd64.apk
RUN sudo apk add --allow-untrusted mssql-tools18_18.2.1.1-1_amd64.apk

# Installing Python dependencies
# Hiding output with -q as there are enconding issues with Windows
RUN pip install -q --upgrade pip setuptools wheel

WORKDIR /dbtproject

# Adding supporting files
COPY ./dbtproject/. /dbtproject/
COPY ./*.sh /
COPY requirements.txt /

RUN pip install --no-cache-dir -r ./../requirements.txt

# Configuring dbt profiles
RUN mkdir /root/.dbt
ADD profiles.yml /root/.dbt

ENV PYTHONUNBUFFERED=1

# RUN chmod 700 /entrypoint.sh

# ENTRYPOINT [ "./entrypoint.sh" ]
CMD [ "/bin/bash", "-c", "dbt build" ]