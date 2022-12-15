#!/bin/bash
# Paul A Bloom
# Dec 12, 2022
# Generate many possible sets of stimtimes in a loop (so we can test for optimization)

for i in {1..5}
do
    bash generate_blocks.sh ${i}
done