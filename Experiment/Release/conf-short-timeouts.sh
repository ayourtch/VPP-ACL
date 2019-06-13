#!/bin/bash
echo "Setting session timeouts"
sudo -E $BINS/vppctl -s /tmp/cli.sock set acl-plugin session timeout udp idle 3
sudo -E $BINS/vppctl -s /tmp/cli.sock set acl-plugin session timeout tcp idle 5
sudo -E $BINS/vppctl -s /tmp/cli.sock set acl-plugin session timeout tcp transient 2
exit

echo "Setting session timeouts 0"
sudo -E $BINS/vppctl -s /tmp/cli.sock set acl-plugin session table max-entries 1000000
sudo -E $BINS/vppctl -s /tmp/cli.sock set acl-plugin session table hash-table-buckets 1000000
sudo -E $BINS/vppctl -s /tmp/cli.sock set acl-plugin session timeout udp idle 60
sudo -E $BINS/vppctl -s /tmp/cli.sock set acl-plugin session timeout tcp idle 3600
sudo -E $BINS/vppctl -s /tmp/cli.sock set acl-plugin session timeout tcp transient 30
exit

echo "Setting session timeouts"
sudo -E $BINS/vppctl -s /tmp/cli.sock set acl-plugin session timeout udp idle 2
sudo -E $BINS/vppctl -s /tmp/cli.sock set acl-plugin session timeout tcp idle 2
sudo -E $BINS/vppctl -s /tmp/cli.sock set acl-plugin session timeout tcp transient 2

