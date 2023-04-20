#!/usr/bin/env bash

#
# build.sh [-v VERSION] [-l LOCALE]
#

function printUsage() {
  cat <<-EOE
build.sh [-v VERSION] [-l LOCALE] [-h]
description:
  Build a Docker image of the specified version of Silverpeas.
  The docker image will be tagged with the version of Silverpeas.
  If no version is passed in the command line, then a Docker image will be 
  built for the version of Silverpeas specified in the Dockerfile.
with:
  -h|--help   Print this help.      
  -v VERSION  The version of Silverpeas. By default the one specified in the
              Dockerfile.
  -l LOCALE   The locale to use. By default en_US.UTF-8.
	EOE
}

function die() {
  echo "Error: $1"
  exit 1
}

function checkNotEmpty() {
  test "Z$1" != "Z" || die "Parameter is empty"
}

version=`grep 'ENV SILVERPEAS_VERSION' Dockerfile | cut -d '=' -f 2`
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -h|--help)
      printUsage
      exit 0
      ;;
    -v)
      checkNotEmpty "$2"
      version="$2"
      git checkout ${version} &>/dev/null
      shift # past argument
      shift # past first value
      ;;
    -l)
      checkNotEmpty "$2"
      locale="--build-arg DEFAULT_LOCALE=$2"
      shift # past argument
      shift # past first value
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
done

echo "Build a docker image for Silverpeas ${version}"
sleep 1
docker build -t ${locale} silverpeas:${version} .
git checkout master &> /dev/null

