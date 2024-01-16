#!/usr/bin/env bash
set -e

#
# Initialization script that wraps the installation, starting and stopping
# of Silverpeas
#

# Creates the Silverpeas global configuration file config.properties from the environment variables
# set in the Docker image
pre_install() {
  if [ -f ${SILVERPEAS_HOME}/configuration/config.properties ]; then
    echo "The configuration file ${SILVERPEAS_HOME}/configuration/config.properties already exists. Does nothing"
    return
  fi

  dbtype=${DB_SERVERTYPE:-POSTGRESQL}
  dbserver=${DB_SERVER:-database}
  dbport=${DB_PORT}
  dbname=${DB_NAME:-Silverpeas}
  dbuser=${DB_USER:-silverpeas}
  dbpassword=${DB_PASSWORD}

  if [ ! "Z${dbpassword}" = "Z" ]; then
    echo "Generate ${SILVERPEAS_HOME}/configuration/config.properties..."
    cat > ${SILVERPEAS_HOME}/configuration/config.properties <<-EOF
DB_SERVERTYPE = $dbtype
DB_SERVER = $dbserver
DB_NAME = $dbname
DB_USER = $dbuser
DB_PASSWORD = $dbpassword
EOF
    test "Z${dbport}" = "Z" || echo "DB_PORT_$dbtype = $dbport" >> ${SILVERPEAS_HOME}/configuration/config.properties
  fi
}

# Start Silverpeas
start_silverpeas() {
  echo "Start Silverpeas..."
  exec ${JBOSS_HOME}/bin/standalone.sh -b 0.0.0.0 -c standalone-full.xml
}

# Stop Silverpeas
stop_silverpeas() {
  echo "Stop Silverpeas..."
  ./silverpeas stop
  local pids=`jobs -p`
  if [ "Z$pids" != "Z" ]; then
    kill $pids &> /dev/null
  fi
}

# Migrate the JCR from Apache Jackrabbit 2 to Apache Jackrabbit Oak
# For doing we have to find out where the JCR home directory is located.
migrate_jcr() {
  # figure out the data home directory (by default it is into the Silverpeas home directory)
  data_home=`grep "SILVERPEAS_DATA_HOME=" ${SILVERPEAS_HOME}/configuration/config.properties  | cut -d '=' -f 2 | xargs`
  if [ "Z${data_home}" = "Z" ]; then
    data_home="${SILVERPEAS_HOME}/data"
  else
    data_home=`sed -e "s/{env./{/g" <<< "${data_home}"`
    data_home=`eval echo -e "${data_home}"`
  fi

  # figure out now the JCR home directory (by default it is located into the data home directory)
  jcr_home=`grep "JCR_HOME[ ]*=" ${SILVERPEAS_HOME}/configuration/config.properties  | cut -d '=' -f 2 | xargs`
  if [ "Z${jcr_home}" = "Z" ]; then
    jcr_home="${data_home}/jcr"
  else    
    jcr_home=`sed -e "s/SILVERPEAS_DATA_HOME/data_home/g" <<< "${jcr_home}"`
    jcr_home=`eval echo -e "${jcr_home}"`
  fi

  jcr_dir=`dirname ${jcr_home}`
  if [ -d "${jcr_dir}/jackrabbit" ] && [ ! -d "${jcr_dir}/jcr/segmentstore" ]; then
    echo "Migrate the JCR from Apache Jackrabbit 2 to Apache Jackrabbit Oak..."
    /opt/oak-migration/oak-migrate.sh "${jcr_dir}/jackrabbit" "${jcr_dir}/jcr"
    test $? -eq 0 || exit 1
  fi
}

trap 'stop_silverpeas' SIGTERM SIGKILL SIGQUIT

if [ -f ${SILVERPEAS_HOME}/bin/.install ]; then
  pre_install
  if [ -f ${SILVERPEAS_HOME}/configuration/config.properties ]; then
    echo "First start: set up Silverpeas..."
    set +e
    ./silverpeas install
    if [ $? -eq 0 ]; then
       rm ${SILVERPEAS_HOME}/bin/.install
       migrate_jcr
       curl -k -i --head https://www.silverpeas.org/ping
    else
      echo "Error while setting up Silverpeas"
      echo
      for f in ${SILVERPEAS_HOME}/log/build-*; do
        cat $f
      done
      exit 1
    fi
    set -e
  else
    echo "No ${SILVERPEAS_HOME}/configuration/config.properties found!"
    exit 1
  fi
fi

if [ -f ${SILVERPEAS_HOME}/configuration/config.properties ] && [ ! -e ${SILVERPEAS_HOME}/bin/.install ]; then
  start_silverpeas
else
  echo "A failure has occurred in the setting up of Silverpeas! No start!"
  exit 1
fi

