#!/bin/bash
#Remember the directory that the running script is in so we can reference patch files
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RUBY_VCLOUD_SDK="/home/tempest-web/tempest/web/vendor/bundle/ruby/2.1.0/gems/ruby_vcloud_sdk-0.7.2"
BOSH_VCLOUD_CPI="/home/tempest-web/tempest/web/vendor/bundle/ruby/2.1.0/gems/bosh_vcloud_cpi-0.7.2"

#Blow up if backups exist
if [ -e "$SCRIPT_DIR/ruby_vcloud_sdk.tgz" ] || [ -e "$SCRIPT_DIR/bosh_vcloud_cpi.tgz" ]
then
  echo "Backup files exist.  If you really want to reapply the patches, then rename or delete the backup files in $SCRIPT_DIR and re-run this script"
  exit
fi

#Backup everything first
echo Backing up ruby_vcloud_sdk
tar -czf $SCRIPT_DIR/ruby_vcloud_sdk.tgz $RUBY_VCLOUD_SDK
echo Backing up bosh_vcloud_cpi
tar -czf $SCRIPT_DIR/bosh_vcloud_cpi.tgz $BOSH_VCLOUD_CPI

#Go to ruby_vcloud_sdk
cd /home/tempest-web/tempest/web/vendor/bundle/ruby/2.1.0/gems/ruby_vcloud_sdk-0.7.2

#Apply fix to ruby_vcloud_sdk
patch -p1 < $SCRIPT_DIR/connection.patch

#Go to bosh_vcloud_cpi
cd /home/tempest-web/tempest/web/vendor/bundle/ruby/2.1.0/gems/bosh_vcloud_cpi-0.7.2

#Apply fix to bosh_vcloud_cpi
patch -p1 < $SCRIPT_DIR/tasks.patch
