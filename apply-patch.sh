#!/bin/bash

DIRECTOR_BASE="/var/vcap/data/packages/director"
TEMPEST_BASE="/home/tempest-web/tempest/web"

#First, make sure we are on the right VM
if [ -e "$DIRECTOR_BASE" ]
then
  VM="director"
elif [ -e "$TEMPEST_BASE" ]
then
  VM="tempest"
  OPSMGRVERFILE=$(<$TEMPEST_BASE/VERSION)
  if [[ $OPSMGRVERFILE =~ ^1\.5.* ]]
  then
    TEMPEST_GEM_BASE="$TEMPEST_BASE/vendor/bundle/ruby/2.2.0/gems"
    OPSMGRVER="1.5"
  elif [[ $OPSMGRVERFILE =~ ^1\.4.* ]]
  then
    TEMPEST_GEM_BASE="$TEMPEST_BASE/vendor/bundle/ruby/2.1.0/gems"
    OPSMGRVER="1.4"
  else
    echo "This machine looks like an Ops Manager VM, but it appears to be running version $OPSMGRVERFILE which isn't currently supported by the script."
    exit
  fi
  echo "Found version $OPSMGRVERFILE of Ops Manager"
else
  echo "This machine does not appear to be Ops Manager or the Director VM, or it is running a version that isn't supported by this patch.  Please ensure you are on the right machine before running this script, and that you are running it as root."
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
  RUBY_VCLOUD_SDK="$TEMPEST_GEM_BASE/ruby_vcloud_sdk-0.7.2"
  if [[ "$OPSMGRVER" == "1.5" ]]; then
    BOSH_VCLOUD_CPI="$TEMPEST_GEM_BASE/bosh_vcloud_cpi-0.7.7"
  else
    BOSH_VCLOUD_CPI="$TEMPEST_GEM_BASE/bosh_vcloud_cpi-0.7.2"
  fi

  #Backup ruby_vcloud_sdk first
  echo Backing up ruby_vcloud_sdk
  tar -czf $SCRIPT_DIR/ruby_vcloud_sdk.tgz $RUBY_VCLOUD_SDK

  #Go to ruby_vcloud_sdk
  cd $RUBY_VCLOUD_SDK 

  #Apply fix to ruby_vcloud_sdk
  if [[ "$OPSMGRVER" == "'1.4" ]]
  then
    echo "Applying connection.patch"
    patch -p1 < $SCRIPT_DIR/connection.patch
  elif [[ "$OPSMGRVER" == "1.5" ]]
  then
    echo "Applying ruby_vcloud_sdk_authandbase64.patch"
    patch -p1 < $SCRIPT_DIR/ruby_vcloud_sdk_authandbase64.patch
  else
    echo "Could not decide on which patch to apply to ruby_vcloud_sdk.  The patcher doesn't understand how to patch this VM."
    exit
  fi
else
  BOSH_VCLOUD_GEMS="$DIRECTOR_BASE/$( ls $DIRECTOR_BASE )/gem_home/ruby/2.1.0/gems"
  if [ -d "$BOSH_VCLOUD_GEMS/bosh_vcloud_cpi-0.7.2" ]
  then
    BOSH_VCLOUD_CPI_VER="0.7.2"
  elif [ -d "$BOSH_VCLOUD_GEMS/bosh_vcloud_cpi-0.7.7" ]
  then
    BOSH_VCLOUD_CPI_VER="0.7.7"
  else
    echo "Could not find a bosh_vcloud_cpi version that this script understands how to patch."
    exit
  fi
  BOSH_VCLOUD_CPI="$BOSH_VCLOUD_GEMS/bosh_vcloud_cpi-$BOSH_VCLOUD_CPI_VER"
fi
  
echo Backing up bosh_vcloud_cpi
tar -czf $SCRIPT_DIR/bosh_vcloud_cpi.tgz $BOSH_VCLOUD_CPI

#Go to bosh_vcloud_cpi
cd $BOSH_VCLOUD_CPI

#Apply fix to bosh_vcloud_cpi
if [[ "$OPSMGRVER" == "1.4" || "$BOSH_VCLOUD_CPI_VER" == "0.7.2" ]]
then
  echo "Applying tasks.patch"
  patch -p1 < $SCRIPT_DIR/tasks.patch
elif [[ "$OPSMGRVER" == "1.5" || "$BOSH_VCLOUD_CPI_VER" == "0.7.7" ]]
then
  echo "Applying bosh_vcloud_cpi_0.7.7_base64.patch"
  patch -p1 < $SCRIPT_DIR/bosh_vcloud_cpi_0.7.7_base64.patch
else
  echo "Warning!  Could not decide on which patch to apply to bosh_vcloud_cpi.  The patcher may not be able to patch this VM"
fi
