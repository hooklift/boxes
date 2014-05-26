#!/usr/bin/env bash
# Copyright (c) 2014 Cloudescape. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -e -o pipefail

list() {
    echo "Available templates: "

    for t in $(ls **/*.json)
    do
        echo ✱ $t
    done
}

build() {
    local path=${1}

    if [[ -z ${path} || ! -f ${path} ]]; then
        echo "$0: An existing packer template is required" >&2
        exit 1
    fi

    #vmware-iso, virtualbox-iso, etc
    local builder=${2}

    if [[ -n "${builder}" ]]; then
       local onlyOpt="-only ${builder}"
       local provider=`expr "${builder}" : '\(.*\)-.*'`
    fi

    # Split path by /
    # path has the following form: coreos/coreos-324.1.0.json
    local parts=''
    OIFS=$IFS
    IFS='/' read -a parts <<< "${path}"
    IFS=$OIFS

    local os=${parts[0]}
    local tmpl=${parts[1]}

    local version=`expr "${tmpl}" : '.*-\(.*\).json'`

    #Packer templates use this variable to download the correct ISO for the given version
    export OS_VERSION=${version}

    local box="$os-$version"
    rm -rf output/${provider}*/${box}

    local cwd=$(pwd)
    cd $os && packer build ${onlyOpt} ${tmpl}
    cd ${cwd}

    #Packaging one box
    echo "Packaging box..."
    if [[ -z ${provider} ]]; then
        local providers=$(ls output)
    else
        local providers=${provider}
    fi

    for p in ${providers}
    do
        cd output/${p}
        tar cvzf "${box}-${p}.box" "${box}"
        rm -rf "${box}"
        cd ${cwd}
    done
    echo "Success!"
}

usage() {
    echo "
    NAME:
       Make.sh - Builds Dobby boxes

    USAGE:
       ./make.sh <target> <template> <provider> Available providers are the same seen for builders in Packer.

    TARGETS:
        list    List available Packer templates
        build   Builds a box for a given provider. By default, it builds all boxes for all providers
        release Compresses boxes and uploads them to Github
        all Builds all the boxes for all the providers

    EXAMPLES:
        $ ./make.sh list

        Available templates:
        ✱ coreos/coreos-324.1.0.json
        ✱ coreos/coreos-alpha.json
        ✱ coreos/coreos-beta.json

        # While working on templates you will find yourself running this often
        $ ./make.sh build coreos/coreos-324.1.0.json vmware-iso
"
    exit 0
}

case $1 in
    list)
        list
        ;;
    build)
        if [[ -z ${2} ]]; then
            for t in $(ls **/*.json)
            do
                build ${t} ${3}
            done
            exit 0
        fi

        build ${2} ${3}
        ;;
    *)
        usage
        ;;
esac
