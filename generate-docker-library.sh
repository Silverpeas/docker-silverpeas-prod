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

isFirst=1
lastMainVersion=""
count=0
for tag in `git tag | tac`; do
  # the version is always in the form x.y.z: any postfix in the tag is removed (6.3.6-jammy -> 6.3.6)
  # and a tag with only two numbers is completed with a 0 (6.4 -> 6.4.0)
  version=`echo $tag | grep -oE "^[0-9]+\.[0-9]+(\.[0-9]+)?"`
  test -z "$version" && continue
  mainVersion=`echo $version | grep -oE "^[0-9]+\.[0-9]+"`
  test "$version" = "$mainVersion" && version="${version}.0"

  if [ "$mainVersion" != "$lastMainVersion" ]; then
    lastMainVersion="$mainVersion"
  else
    continue
  fi

  test $count -eq 2 && break

  count=$(( count + 1 ))
  commit=`git rev-parse ${tag}`
  fetch="${mainVersion}.x"
  if [ $isFirst -eq 1 ]; then
    isFirst=0
    printVersion "${version}, latest" ${commit} ${fetch}
  else
    printVersion "${version}, ${mainVersion}" ${commit} ${fetch}
  fi
done
