#!/bin/bash

# We need to be able to pass env variables
# through sudo when running CoreOS install. 
# For instance, the CoreOS version to download specific images
echo "Defaults !env_reset" > /etc/sudoers.d/dobby
