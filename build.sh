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
    export OS_VERSION=${version}

    rm -rf output/${provider}*/${os}*

    cd $os && packer build ${onlyOpt} ${tmpl}
}

usage() {
    echo "
    NAME:
       Make - Builds Dobby boxes and manages releases

    USAGE:
       ./make <target> [-provider=vmware] Available providers are the same seen in Packer.

    TARGETS:
        list    List available Packer templates
        build   Builds a box for a given provider. By default, it builds all boxes for vmware
        release Compresses boxes and uploads them to Github
        all Builds all the boxes for all the providers

    EXAMPLES:
        $ ./make list

        Available templates:
        ✱ coreos/coreos-324.1.0.json
        ✱ coreos/coreos-alpha.json
        ✱ coreos/coreos-beta.json

        # While working on templates you will find yourself running this often
        $ ./make build coreos/coreos-324.1.0.json vmware-iso
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
    release)
        release ${2} ${3}
        ;;
    *)
        usage
        ;;
esac
