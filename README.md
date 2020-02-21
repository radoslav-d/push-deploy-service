# Push custom deploy service

## Overall description 
The main idea of this script is to automate the building of repositories/projects and deploying a local deploy service to CloudFoundry.
The script goes though local repositories of deploy service components (`cf-java-client-sap`, `multiapps`, `multiapps-controller`, `xsa-multiapps-controller`) and checks if there are new changes with `git status`.
The changed repositories are build with `mvn clean install` and lastly the deploy service is pushed with `cf push`.

## Prerequisites

 - Maven and Java
 - cloned repos: `cf-java-client-sap`, `multiapps`, `multiapps-controller`, `xsa-multiapps-controller`
 - Installed CF client
 - Login in `cf`
 - Set params in `set-params.sh`

## Parameters
In order to run push the deploy service, you need to set several parameters, which will be used though the process.
These parameters can be found in `set-params.sh` and they are as follows:

 - `CF_CLIENT_REPO`: the location of the local `cf-java-client-sap` repo;
 - `MULTIAPPS_REPO`: the location of the local `multiapps` repo;
 - `CONTROLLER_REPO`: the location of the local `multiapps-controller` repo;
 - `XSA_REPO`: the location of the local `xsa-multiapps-controller` repo;
 - `OUTPUTS`: the directory where the output logs of `mvn` and `cf` commands will be saved;
 - `DEPLOY_SERVICE_HOST`: the host of the deploy service `cf-java-client-sap`;
 - `DEPLOY_SERVICE_DOMAIN`: the domain of the deploy service (depends on cf).
