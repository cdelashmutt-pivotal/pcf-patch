#!/bin/bash
if [ -e ruby_vcloud_sdk.tgz ]
then
  tar -xzvf ruby_vcloud_sdk.tgz -C /
fi
tar -xzvf bosh_vcloud_cpi.tgz -C /
