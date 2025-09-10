#!/usr/bin/env bash
echo 10000000 | sudo tee /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw
echo 36000000 | sudo tee /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_1_power_limit_uw
echo 36000000 | sudo tee /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_2_power_limit_uw
