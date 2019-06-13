#!/bin/bash

VPPFIX="vpp3653"

# args: 1k_1 acl1

dir=$1
seed=$2

dt=$(date '+%d-%m_%H-%M');
dts=$(date '+%d-%m');
echo "$dt"

sudo killall vpp_main
sleep 5

# export BINS=/home/ayourtch/vpp/build-root/install-vpp_debug-native/vpp/bin

export STARTUP_CONF="/home/ayourtch/VPP-ACL/vpp-bench//startup-rubina2.conf"

echo "VPP START DEFAULT: $VPPFIX"
sh $EXP_VPP/conf-dummy-acl.sh $VPPFIX $acl_rules
sleep 2

sh $EXP_VPP/conf-bridge.sh $VPPFIX

sh $EXP_VPP/conf-short-timeouts.sh $VPPFIX

cd $EXP_VPP/elog_parser
pwd

echo "ELOG clean"
sh elog_clean.sh

mkdir -p $EXP_RES/results_$dts/$classe_exp\_$dir
echo "\n" > $EXP_RES/results_$dts/$classe_exp\_$dir/MG_$name_exp.out

echo "Perf record start"
# sudo perf record -C 0 -o /tmp/ayourtch_vpp_perf_record &
# sudo perf record -C 4 -e mem_load_uops_retired.l3_miss -o /tmp/ayourtch_vpp_perf_record &
sudo perf record -C 4 -o /tmp/ayourtch_vpp_perf_record &
# sudo perf record -C 2 -o /tmp/ayourtch_vpp_perf_record &

echo VPP trace start
sudo -E $BINS/vppctl -s /tmp/cli.sock trace add dpdk-input 50

ps -ef | grep vpp | grep install | grep -v sudo | grep -v grep | grep -v make

echo attach gdb and PRESS ENTER
read ASDASD

echo "TREX"
# echo "sudo $MOONGEN_PATH/build/MoonGen $MGSCR/tr_gen_timer.lua --dpdk-config=$CONFIG_DIR/dpdk-conf.lua 1 0 $RULESET/trace_shot/$dir/$tfilename > tmp.out"
# sudo $MOONGEN_PATH/build/MoonGen $MGSCR/tr_gen_timer.lua --dpdk-config=$CONFIG_DIR/dpdk-conf.lua 1 0 $RULESET/trace_shot/$dir/$tfilename > tmp.out
# echo PRESS ENTER
#read ASDASD
# (cd /home/ayourtch/trex/v2.30; sudo ./t-rex-64 -f cap2/sfr.yaml  -c 1  -m 30 -d 6000)
# (cd /home/ayourtch/trex/v2.30; sudo ./t-rex-64 -f cap2/sfr.yaml  -c 1 -m 30 -d 60 --active-flows 1000)
# (cd /home/ayourtch/trex/v2.30; sudo ./t-rex-64 -f cap2/sfr.yaml  -m 10  -d  100000)
(cd /home/ayourtch/trex/v2.30; sudo ./t-rex-64 -f cap2/sfr.yaml  -m 30  -d  100000)

echo "Stop perf record"
sudo killall perf


sudo -E $BINS/vppctl -s /tmp/cli.sock show run >/tmp/show-run.txt
sudo -E $BINS/vppctl -s /tmp/cli.sock show event-logger >/tmp/show-event-logger.txt
sudo -E $BINS/vppctl -s /tmp/cli.sock show acl sess >/tmp/ay-show-acl-sessions

cd -
pwd

sudo killall vpp_main
sudo rm /tmp/cli.sock


