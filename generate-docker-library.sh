#!/usr/bin/env bash

cat <<-EOH
# This file is generated via https://github.com/Silverpeas/docker-silverpeas-prod/blob/master/generate-docker-library.sh
Maintainers: Miguel Moquillon <miguel.moquillon@silverpeas.org> (@mmoqui)
GitRepo: https://github.com/Silverpeas/docker-silverpeas-prod.git
EOH

function printVersion() {
  cat <<-EOE

Tags: $1
GitCommit: $2
GitFetch: refs/heads/$3
	EOE
}

