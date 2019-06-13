#!/bin/bash

VPPFIX="vpp3653"
sudo modprobe uio_pci_generic
sudo dpdk-devbind -b uio_pci_generic 0000:81:00.0 0000:81:00.1 0000:03:00.0 0000:03:00.1


# args: 1k_1 acl1

dir=$1
seed=$2

dt=$(date '+%d-%m_%H-%M');
dts=$(date '+%d-%m');
echo "$dt"

mkdir -p $EXP_RES/results_$dts/Partition_$dts/ 
echo "______$dir\__$seed____" 
echo "______$dir\__$seed____" >> $EXP_RES/results_$dts/Partition_$dts/$seed\_collisions.out
echo "______$dir\__$seed____" >> $EXP_RES/results_$dts/Partition_$dts/$seed\_d-parti.out
echo "______$dir\__$seed____" >> $EXP_RES/results_$dts/Partition_$dts/$seed\_partition.out

# ayourtch
# for acl_rules in $RULESET/$dir/$seed*.rules;

echo rules are in $RULESET/$dir/${seed}_seed_1.rules 

for acl_rules in $RULESET/$dir/${seed}_seed_1.rules;
do
rfilename="${acl_rules##/*/}"
tfilename=$rfilename\_trace
name_exp="${rfilename%\.r*}"
classe_exp="${rfilename%%\_*}"

echo "Ruleset: $acl_rules || $rfilename  || $tfilename"
echo "Classe: $classe_exp || $name_exp"

sudo killall vpp_main
sleep 5

echo "VPP START DEFAULT: $VPPFIX"
sh $EXP_VPP/conf-acl-stateless.sh $VPPFIX $acl_rules
sleep 2

sh $EXP_VPP/conf-xc.sh $VPPFIX
# sh $EXP_VPP/conf-bridge.sh $VPPFIX

cd $EXP_VPP/elog_parser
pwd

echo "ELOG clean"
sh elog_clean.sh

mkdir -p $EXP_RES/results_$dts/$classe_exp\_$dir
echo "\n" > $EXP_RES/results_$dts/$classe_exp\_$dir/MG_$name_exp.out

echo "Perf record start"
sudo perf record -C 0 -o /tmp/ayourtch_vpp_perf_record &

echo VPP trace start
sudo -E $BINS/vppctl -s /tmp/cli.sock trace add dpdk-input 50

echo "MoonGen"
echo "sudo $MOONGEN_PATH/build/MoonGen $MGSCR/tr_gen_timer.lua --dpdk-config=$CONFIG_DIR/dpdk-conf.lua 1 0 $RULESET/trace_shot/$dir/$tfilename > tmp.out"
sudo $MOONGEN_PATH/build/MoonGen $MGSCR/tr_gen_timer.lua --dpdk-config=$CONFIG_DIR/dpdk-conf.lua 1 0 $RULESET/trace_shot/$dir/$tfilename > tmp.out
echo PRESS ENTER
# read ASDASD

echo "Stop perf record"
sudo killall perf

cat tmp.out
cat tmp.out >> $EXP_RES/results_$dts/$classe_exp\_$dir/MG_$name_exp.out
rm tmp.out

echo "ELOG dump"
sh elog_clk.sh

sed -n 10,20p clk_output_elog
cat clk_output_elog > $EXP_RES/results_$dts/$classe_exp\_$dir/Elog_$name_exp.out
cat clk_output_elog >> $EXP_RES/results_$dts/$classe_exp\_$dir/Elog_$seed.out
rm clk_output_elog 
#mv clk_output_elog $EXP_RES/results/$classe_exp/Elog_$name_exp.out




echo "'''''''''''''''"
echo "'''Partition'''"
echo "sudo -E $BINS/vppctl -s /tmp/cli.sock acl-plugin show partition sw_if_index 2 input 0 > tmp.out"
sudo -E $BINS/vppctl -s /tmp/cli.sock acl-plugin show partition lc_index 0   > tmp.out

cat tmp.out
cat tmp.out >> $EXP_RES/results_$dts/Partition_$dts/$seed\_partition.out
rm tmp.out


echo "sudo -E $BINS/vppctl -s /tmp/cli.sock acl-plugin show collisions sw_if_index 2 input 0"
sudo -E $BINS/vppctl -s /tmp/cli.sock acl-plugin show collisions lc_index 0| awk '{print $5}' | sort |uniq -c > tmp.out

cat tmp.out
cat tmp.out >> $EXP_RES/results_$dts/Partition_$dts/$seed\_collisions.out
rm tmp.out


sudo -E $BINS/vppctl -s /tmp/cli.sock show acl-plugin acl | tee /tmp/acl-data

echo "sudo -E $BINS/vppctl -s /tmp/cli.sock acl-plugin show d-partition sw_if_index 2 input 0 > tmp.out"
sudo -E $BINS/vppctl -s /tmp/cli.sock acl-plugin show d-partition lc_index 0 > tmp.out

cat tmp.out
cat tmp.out >> $EXP_RES/results_$dts/Partition_$dts/$seed\_d-parti.out
rm tmp.out

# sudo -E $BINS/vppctl -s /tmp/cli.sock show acl-plugin tables applied >> tmp.out
sudo -E $BINS/vppctl -s /tmp/cli.sock show acl-plugin sess >> tmp.out
# sudo -E $BINS/vppctl -s /tmp/cli.sock show trace >> tmp.out
cat tmp.out
cat tmp.out >> $EXP_RES/results_$dts/Partition_$dts/$seed\_applied-tables.out
rm tmp.out

cd -
pwd

done

echo "mv $EXP_RES/results_$dts/$classe_exp\_$dir $EXP_RES/results_$dts/$classe_exp\_clk_$dt"
mv $EXP_RES/results_$dts/$classe_exp\_$dir $EXP_RES/results_$dts/$classe_exp\_$dir\_clk_$dt

sudo killall vpp_main
sudo rm /tmp/cli.sock


#show the results
(cd $EXP_RES/results_$dts/; pwd; find . -name 'MG_*seed_1.out'  -exec grep -H RX: {} \;) | sort

