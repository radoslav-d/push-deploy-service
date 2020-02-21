#!/bin/bash

# change this params depending on your env
export CF_CLIENT_REPO=~/Desktop/Workspace/MTA/cf-java-client-sap
export MULTIAPPS_REPO=~/Desktop/Workspace/MTA/multiapps
export CONTROLLER_REPO=~/Desktop/Workspace/MTA/multiapps-controller
export XSA_REPO=~/Desktop/Workspace/MTA/xsa-multiapps-controller
export OUTPUTS=~/Desktop/Workspace/MTA/logs
export DEPLOY_SERVICE_HOST="deploy-service-i530753"

function main() {
    build_if_changed $CF_CLIENT_REPO
    CF_CLIENT_CHANGED=$?
    build_if_changed $MULTIAPPS_REPO
    MULTIAPPS_CHANGED=$?

    if [ $CF_CLIENT_CHANGED -eq 0 ] || [ $MULTIAPPS_CHANGED -eq 0 ] ; then
        build_if_changed $CONTROLLER_REPO true
        CONTROLLER_CHANGED=$?
    else
        build_if_changed $CONTROLLER_REPO
        CONTROLLER_CHANGED=$?
    fi

    if [ $CF_CLIENT_CHANGED -eq 0 ] || [ $MULTIAPPS_CHANGED -eq 0 ] || [ $CONTROLLER_CHANGED -eq 0 ] ; then
        build_if_changed $XSA_REPO true
        XSA_CHANGED=$?
    else
        build_if_changed $XSA_REPO
        XSA_CHANGED=$?
    fi

    if [ $XSA_CHANGED -eq 0 ] ; then
        push_deploy_service
    fi
}

function build_if_changed() {
    local repo_location=$1
    local ignore_git_changes=$2

    cd $repo_location
    pwd
    git status | grep "nothing to commit"

    if [[ $? -ne 0 ]] ; then
        echo "Detected changes in ${repo_location}"
        mvn_clean_install
    elif [ ! -z $ignore_git_changes ] ; then
        echo "Changes in ${repo_location} not detected, but will build anyway"
        mvn_clean_install
    else
        echo "No changes in ${repo_location}"
        return 1
    fi
    return 0
}

function mvn_clean_install() {
    uuid=$(uuidgen)
    location=$(pwd)
    echo "Running mvn clean install in ${location}"
    echo "The output is recorded to ${OUTPUTS}/${uuid}-mvn-output"
    mvn clean install >$OUTPUTS/$uuid-mvn-output
    echo "Finished mvn clean install"
}

function push_deploy_service() {
    uuid=$(uuidgen)
    echo "Pushing deploy service"
    echo "The output is recorded to ${OUTPUTS}/${uuid}-cf-p-output"
    cf p -f "${XSA_REPO}/com.sap.cloud.lm.sl.xs2.web/target/manifests/manifest.yml" -n $DEPLOY_SERVICE_HOST -i 1 >$OUTPUTS/$uuid-cf-p-output
    echo "Finished cf push"
    export DEPLOY_SERVICE_URL="${DEPLOY_SERVICE_HOST}.cfapps.sap.hana.ondemand.com"
}

# run the script
main
