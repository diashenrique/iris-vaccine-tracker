# ARG IMAGE=intersystemsdc/iris-community:2020.3.0.221.0-zpm

ARG IMAGE=intersystemsdc/iris-community-arm64:2020.4.0.524.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.4.0.524.0-zpm
ARG IMAGE=intersystemsdc/iris-community
FROM $IMAGE

USER root   
        
WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp
USER ${ISC_PACKAGE_MGRUSER}

# COPY Installer.cls .
COPY data data
COPY src src
COPY iris.script /tmp/iris.script
COPY module.xml module.xml

RUN iris start IRIS \
	&& iris session IRIS < /tmp/iris.script \
    && iris stop IRIS quietly
