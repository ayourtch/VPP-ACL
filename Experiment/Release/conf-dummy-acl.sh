#!/bin/bash
sudo killall vpp_main
sleep 2

echo "VPP START DEFAULT: $1"
$CONFIG_DIR/vpp_start-default.sh 2>&1 >/tmp/vpp-log &
sleep 15

export APICALL="sudo -E $BINS/vppctl -s /tmp/cli.sock bin "


echo "Adding dummy ACLs"

# this would make it permit+reflect, mainly testing the stateful path
$APICALL acl_add_replace permit+reflect tag inAcceptReflect 
$APICALL acl_add_replace permit+reflect tag default 

$APICALL acl_interface_add_del sw_if_index 1 add input acl 0
$APICALL acl_interface_add_del sw_if_index 2 add input acl 0
$APICALL acl_interface_add_del sw_if_index 1 add output acl 1
$APICALL acl_interface_add_del sw_if_index 2 add output acl 1
