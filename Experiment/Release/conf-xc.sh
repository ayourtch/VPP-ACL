#!/bin/bash


echo "Setting Up interfaces"
sudo -E $BINS/vppctl -s /tmp/cli.sock set int state TenGigabitEthernet2/0/0 up
sudo -E $BINS/vppctl -s /tmp/cli.sock set int state TenGigabitEthernet2/0/1 up

echo "Setting Xconnect 0->1"
sudo -E $BINS/vppctl -s /tmp/cli.sock set int l2 xconnect TenGigabitEthernet2/0/1 TenGigabitEthernet2/0/0
echo "Setting Xconnect 1->0"
sudo -E $BINS/vppctl -s /tmp/cli.sock set int l2 xconnect TenGigabitEthernet2/0/0 TenGigabitEthernet2/0/1


