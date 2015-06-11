#!/bin/bash
#Remember the directory that the running script is in so we can reference patch files
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#Go to ruby_vcloud_sdk
cd /home/tempest-web/tempest/web/vendor/bundle/ruby/2.1.0/gems/ruby_vcloud_sdk-0.7.2

#Apply fix to ruby_vcloud_sdk
patch -p1 < $SCRIPT_DIR/connection.patch

#Go to bosh_vcloud_cpi
cd /home/tempest-web/tempest/web/vendor/bundle/ruby/2.1.0/gems/bosh_vcloud_cpi-0.7.2

#Apply fix to bosh_vcloud_cpi
patch -p1 < $SCRIPT_DIR/tasks.patch
