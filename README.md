## intersystems-iris-docker-rest-template
This is a template of a Multi-model REST API application built with ObjectScript in InterSystems IRIS.
It also has OPEN API spec, 
can be developed with Docker and VSCode,
can ve deployed as ZPM module.

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation with ZPM

zpm:USER>install multi-model-api-template

## Installation for development

Create your repository from template.

Clone/git pull the repo into any local directory e.g. like it is shown below (here I show all the examples related to this repository, but I assume you have your own derived from the template):

```
$ git clone git@github.com:intersystems-community/objectscript-rest-docker-template.git
```

Open the terminal in this directory and run:

```
$ docker-compose up -d --build
```

or open the folder in VSCode and do the following:
![rest](https://user-images.githubusercontent.com/2781759/78183327-63569800-7470-11ea-8561-c3b547ce9001.gif)


## How to Work With it

This template creates /crud REST web-application on IRIS which implements 4 types of communication: GET, POST, PUT and DELETE aka CRUD operations.
These interface works with a sample persistent class dc.Sample.Person.

Open http://localhost:52773/swagger-ui/index.html?url=http://localhost:52773/api/mgmnt/v1/USER/spec/crud to test the REST API
# Testing GET requests

To test GET you need to have some data. You can create it with POST request (see below), or you can create some random testing data. to do that call GET on /persons/gen/amount
where amount is a number of records you want to generate.

Call:

```
localhost:52773/crud/persons/gen/10
```
to create 10 random records.

Or generate with call via IRIS Terminal

```
USER>do ##class(dc.Sample.Person).AddTestData(10)
```
This will create 10 random records in dc.Sample.Person class.



This REST API exposes two GET requests: all the data and one record.
To get all the data in JSON call:

```
localhost:52773/crud/persons/all
```

To request the data for a particular record provide the id in GET request like 'localhost:52773/crud/multi/MODEL/id' . E.g.:

```
localhost:52773/crud/multi/object/1
localhost:52773/crud/multi/sql/1
localhost:52773/crud/multi/keyval/1
```

This will return JSON data for the person with ID=1, something like that:

```
{"Name":"Elon Mask","Title":"CEO","Company":"Tesla","Phone":"123-123-1233","DOB":"1982-01-19"}
```

# Testing POST request

Create a POST request e.g. in Postman with raw data in JSON. e.g.

```
{"Name":"Elon Mask","Title":"CEO","Company":"Tesla","Phone":"123-123-1233","DOB":"1982-01-19"}
```

Adjust the authorisation if needed - it is basic for container with default login and password for IRIR Community edition container

and send the POST request to localhost:52773/crud/multi/object/

This will create a record in dc.Sample.Person class of IRIS.

# Testing PUT request

PUT request could be used to update the records. This needs to send the similar JSON as in POST request above supplying the id of the updated record in URL.
E.g. we want to change the record with id=5. Prepare in Postman the JSON in raw like following:

```
{"Name":"Jeff Besos","Title":"CEO","Company":"Amazon","Phone":"123-123-1233","DOB":"1982-01-19"}
```

and send the put request to:
```
localhost:52773/crud/multi/object/5
```

# Testing DELETE request

For delete request this REST API expects only the id of the record to delete. E.g. if the id=5 the following DELETE call will delete the record via the MODEL you want:

```
localhost:52773/crud/multi/object/5
localhost:52773/crud/multi/sql/5
localhost:52773/crud/multi/keyval/5
```

## How to start coding
This repository is ready to code in VSCode with ObjectScript plugin.
Install [VSCode](https://code.visualstudio.com/) and [ObjectScript](https://marketplace.visualstudio.com/items?itemName=daimor.vscode-objectscript) plugin and open the folder in VSCode.
Open /src/cls/PackageSample/ObjectScript.cls class and try to make changes - it will be compiled in running IRIS docker container.

Feel free to delete PackageSample folder and place your ObjectScript classes in a form
/src/cls/Package/Classname.cls

The script in Installer.cls will import everything you place under /src/cls into IRIS.

## What's insde the repo

# Dockerfile

The simplest dockerfile to start IRIS and load ObjectScript from /src/cls folder
Use the related docker-compose.yml to easily setup additional parametes like port number and where you map keys and host folders.

# .vscode/settings.json

Settings file to let you immedietly code in VSCode with [VSCode ObjectScript plugin](https://marketplace.visualstudio.com/items?itemName=daimor.vscode-objectscript))

# .vscode/launch.json
Config file if you want to debug with VSCode ObjectScript
