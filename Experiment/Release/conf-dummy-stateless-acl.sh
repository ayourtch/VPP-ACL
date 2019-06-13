#!/bin/bash
sudo killall vpp_main
sleep 5

echo "VPP START DEFAULT: $1"
$CONFIG_DIR/vpp_start-default.sh 2>&1 >/tmp/vpp-log &
sleep 10

VAT="sudo -E $BINS/vpp_api_test socket-name /tmp/cli.sock plugin_path $BINS/../lib64/vpp_api_test_plugins/"

echo "Adding dummy ACLs"

# this would make it permit+reflect, mainly testing the stateful path
echo acl_add_replace permit tag inAcceptReflect | $VAT
echo acl_add_replace permit tag default | $VAT

echo acl_interface_add_del sw_if_index 1 add input acl 0 | $VAT
echo acl_interface_add_del sw_if_index 2 add input acl 0 | $VAT
echo acl_interface_add_del sw_if_index 1 add output acl 1 | $VAT
echo acl_interface_add_del sw_if_index 2 add output acl 1 | $VAT




