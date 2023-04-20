# docker-silverpeas-prod

A project that produces a Docker image of [Silverpeas 6](http://www.silverpeas.org) from a template.
It is dedicated for building the [official images of Silverpeas 6](https://hub.docker.com/_/silverpeas/)
in the [Docker Hub](https://hub.docker.com/).

## Docker descriptor generation

The `Dockerfile` used to build a Docker image of Silverpeas 6 is generated from the template 
`Dockerfile.template` by the shell script `generate-dockerfile.sh`. The script accepts two arguments:
the versions of both Silverpeas 6 and Wildfly for which a `Dockerfile` has to be generated.

For example, to generate a Dockerfile for Silverpeas 6.1 and Wildfly 18.0.1:

	$ ./generate-dockerfile.sh 6.1 18.0.1

The generator is dedicated to be used only by ourselves to generate and to tag the `Dockerfile` for 
a new version of Silverpeas. This descriptor will then be used to build the latest official Docker
image of Silverpeas in the Docker Hub.

## Image creation

We provide a shell script `build.sh` to ease the build of a Docker image of Silverpeas.

To know how to use this script, just do:

	$ ./build.sh -h

To build the Docker image of the latest version of Silverpeas, id est the version of Silverpeas for 
which the current `Dockerfile` was generated:

	$ ./build.sh

To build an image for a given version of Silverpeas 6, say 6.1:

	$ ./build.sh -v 6.1

This will checkout the tag 6.1 and then build the image from the `Dockerfile` at this tag.

By default, the image is created with as default locale `en_US.UTF-8`. To specify another locale, for example `fr_FR.UTF-8`, just do:

	$ ./build.sh -l fr_FR.UTF-8

## How to use this image

For an explanation of how to use the Docker images of Silverpeas, please read carefully the 
documentation up-to-day in our [Official Silverpeas Repository](https://hub.docker.com/_/silverpeas/) 
in the [Docker Hub](https://hub.docker.com/).

## Docker compose

You can bootstrap a Docker environment with Silverpeas and the PostgreSQL database for Silverpeas by using Docker Compose.

For doing, an excerpt of a Docker compose descriptor `docker-compose.yml` is provided. It depends on the environment variables defined in the `silverpeas.env` file. To use it, just copy `silverpeas.env` to `.env` and adjust the values of the variables in the file to your requirement. Then:

	$ docker compose up

to launch both the PostgreSQL and Silverpeas services. At creation of the Silverpeas service, Silverpeas will be automatically reconfigured to use the PostgreSQL database as defined in the `.env` file.

To stop the services:

	$ docker compose stop

To start again the services:

	$ docker compose start

Once the services are started, you can connect to the container running Silverpeas:

	$ docker exec -u root -it silverpeas /bin/bash

Inside the container, you can then update by hand the configuration of Silverpeas and Wildfly.