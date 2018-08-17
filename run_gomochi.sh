#!/bin/bash
NSNAME="$1"
export CUDA_VISIBLE_DEVICES="$2"
./gomochi d-${NSNAME} -s250000 -q1
export PS1="(${NSNAME}) \\u@\\h:\\w\\\$ "
exec bash --norc
