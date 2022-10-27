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

DRONE_OUTPUT_TOPICS="\
        /firefly/desired_topic\
        /firefly/desired_topic\
        /firefly/desired_topic\
        /firefly/desired_topic\
        /firefly/desired_topic\
        /firefly/desired_topic\
        /firefly/desired_topic\
        /firefly/desired_topic\
        /firefly/desired_topic\
        /firefly/desired_topic\
        /firefly/desired_topic\
        /firefly/desired_topic\
        /firefly/desired_topic\
        /firefly/desired_topic\
        /firefly/desired_topic\
        /firefly/desired_topic\
        /firefly/desired_topic"

DRONE_CMD_TOPICS="\
        /drone/command/desired_topic \
        /drone/command/desired_topic \
        /drone/command/desired_topic \
        /drone/command/desired_topic \
        /drone/command/desired_topic \
        /drone/command/desired_topic \
        /drone/command/desired_topic"

ESTIMATE_TOPICS="\
        /estimate/dnn_cv/heading \
        /estimate/dnn_cv/position \
        /estimate/ekf \
        /estimate/tcv/pose"

QUAlISYS_TOPICS="\
        /qualisys/Anafi/odom \
        /qualisys/Anafi/pose \
        /qualisys/Anafi/velocity \
        /qualisys/Platform/odom \
        /qualisys/Platform/pose \
        /qualisys/Platform/velocity"

GNC_TOPICS="/guidance/pure_pursuit/velocity_reference \
        /guidance/pid/velocity_reference"

STANDARD_TOPICS="$DRONE_OUTPUT_TOPICS \
        $ANAFI_CMD_TOPICS \
        $DARKNET_TOPICS \
        $ESTIMATE_TOPICS \
        $GNC_TOPICS \
        /tf \
        /anafi/msg_latency"

if [[ $ENV == "sim" ]]; then
    echo "Rosbagging sim topics"
    rosbag record -O $OUTPUT_DIR/$TIME \
        $STANDARD_TOPICS 
elif [[ $ENV == "lab" ]]; then
    echo "Rosbagging lab topics"
    rosbag record -O $OUTPUT_DIR/$TIME \
        $STANDARD_TOPICS \
        $QUAlISYS_TOPICS 
fi
