#!/bin/bash

DIRECTOR_BASE="/var/vcap/data/packages/director"
TEMPEST_BASE="/home/tempest-web/tempest/web/vendor/bundle/ruby/2.1.0/gems"

#First, make sure we are on the right VM
if [ -e "$DIRECTOR_BASE" ]
then
  VM="director"
elif [ -e "$TEMPEST_BASE" ]
then
  VM="tempest"
else
  echo This machine does not appear to be Ops Manager or the Director VM.  Please ensure you are on the right machine before running this script, and that you are running it as root.
  exit
fi

#Remember the directory that the running script is in so we can reference patch files
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#Blow up if backups exist
if [ -e "$SCRIPT_DIR/ruby_vcloud_sdk.tgz" ] || [ -e "$SCRIPT_DIR/bosh_vcloud_cpi.tgz" ]
then
  echo "Backup files exist.  If you really want to reapply the patches, then rename or delete the backup files in $SCRIPT_DIR and re-run this script"
  exit
fi

if [ "tempest" == "$VM" ]
then
  RUBY_VCLOUD_SDK="$TEMPEST_BASE/ruby_vcloud_sdk-0.7.2"
  BOSH_VCLOUD_CPI="$TEMPEST_BASE/bosh_vcloud_cpi-0.7.2"

  #Backup ruby_vcloud_sdk first
  echo Backing up ruby_vcloud_sdk
  tar -czf $SCRIPT_DIR/ruby_vcloud_sdk.tgz $RUBY_VCLOUD_SDK

  #Go to ruby_vcloud_sdk
  cd $RUBY_VCLOUD_SDK 

  #Apply fix to ruby_vcloud_sdk
  patch -p1 < $SCRIPT_DIR/connection.patch
else
  BOSH_VCLOUD_CPI="$DIRECTOR_BASE/$( ls $DIRECTOR_BASE )/gem_home/ruby/2.1.0/gems/bosh_vcloud_cpi-0.7.2"
fi
  
echo Backing up bosh_vcloud_cpi
tar -czf $SCRIPT_DIR/bosh_vcloud_cpi.tgz $BOSH_VCLOUD_CPI

#Go to bosh_vcloud_cpi
cd $BOSH_VCLOUD_CPI

#Apply fix to bosh_vcloud_cpi
patch -p1 < $SCRIPT_DIR/tasks.patch
