#!/bin/bash
sudo killall vpp_main
sleep 5

echo "VPP START DEFAULT: $1"
$CONFIG_DIR/vpp_start-default.sh &
sleep 10

:'
echo "Setting Up interfaces"
sudo -E $BINS/vppctl -s /tmp/cli.sock set int state TenGigabitEthernetb/0/1 up

sudo -E $BINS/vppctl -s /tmp/cli.sock set int state TenGigabitEthernetb/0/0 up

echo "Setting Xconnect 1->0"
sudo -E $BINS/vppctl -s /tmp/cli.sock set int l2 xconnect TenGigabitEthernetb/0/1 TenGigabitEthernetb/0/0
'


echo "Parsing ruleset: $2"
# this would make it permit-only
# echo acl_add_replace_from_file filename $2 permit append-default-permit | sudo -E $BINS/vpp_api_test socket-name /tmp/cli.sock plugin_path $BINS/../lib64/vpp_api_test_plugins/

# this would make it permit+reflect, mainly testing the stateful path
echo acl_add_replace_from_file filename $2 permit append-default-permit | sudo -E $BINS/vpp_api_test socket-name /tmp/cli.sock plugin_path $BINS/../lib64/vpp_api_test_plugins/
# sudo -E $BINS/vppctl -s /tmp/cli.sock acl-plugin add filename $2 permit

#sudo -E $BINS/vppctl -s /tmp/cli.sock acl-plugin add filename /home/valerio/Ruleset/1k_1/acl1_seed_1.rules

echo "Applying rules"
#sudo -E $BINS/vppctl -s /tmp/cli.sockacl-plugin apply sw_if_index 2 input 0 1


echo acl_interface_set_acl_list sw_if_index 2 input 0 | sudo -E $BINS/vpp_api_test socket-name /tmp/cli.sock plugin_path $BINS/../lib64/vpp_api_test_plugins/
# sudo -E $BINS/vppctl -s /tmp/cli.sock acl-plugin apply sw_if_index 2 input 0

sudo -E $BINS/vppctl -s /tmp/cli.sock acl-plugin show partition lc_index 0 

#echo "ACL_VAT"
#sudo $SFLAG $BINS/vpp_api_test chroot prefix $1 plugin_path $VPP_PLUGIN_PATH in /home/valerio/vpp1704/vat-acl-script


