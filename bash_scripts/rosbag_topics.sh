#!/bin/bash

usage="Usage: $(basename "$0") <test-name> <env (sim/lab)>"

if [ $# -ne 2 ]
  then
    echo $usage
    exit
fi

TEST_NAME=$1
ENV=$2
SCRIPT_DIR=$(dirname "$(realpath $0)")

OUTPUT_DIR=$SCRIPT_DIR/../out/rosbag/$ENV/$TEST_NAME
mkdir -p $OUTPUT_DIR

if [ -e $OUTPUT_DIR/*.bag ]
then
    OLD_DIR=$OUTPUT_DIR/old
    echo "Moving old bagfile into "$OLD_DIR""
    mkdir -p $OLD_DIR
    mv $OUTPUT_DIR/*.bag $OLD_DIR
fi

TIME=$(date +%Y-%m-%d-%H-%M-%S)

DRONE_CMD_TOPICS="\
        /firefly/command/current_reference \
        /firefly/command/roll_pitch_yaw_rate_thrust \
        /firefly/command/trajectory \
        /firefly/command/pose"

QUALISYS_TOPICS="\
        /qualisys/firefly/odom \
        /qualisys/firefly/pose \
        /qualisys/firefly/velocity"

SIM_TOPICS="\
        /firefly/ground_truth/pose"

STANDARD_TOPICS="\
        $DRONE_CMD_TOPICS \
        /tf"

if [[ $ENV == "sim" ]]; then
    echo "Rosbagging sim topics"
    rosbag record -O $OUTPUT_DIR/$TIME \
        $STANDARD_TOPICS \
        $SIM_TOPICS
elif [[ $ENV == "lab" ]]; then
    echo "Rosbagging lab topics"
    rosbag record -O $OUTPUT_DIR/$TIME \
        $STANDARD_TOPICS \
        $QUALISYS_TOPICS 
fi
