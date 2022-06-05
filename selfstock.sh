#!/bin/bash
# Connect two instances of cli stockfish so they can play each other
# from a given initial position. 
#
# USAGE:
#
#
# BACKGROUND:
#
# Although several chess programs offer the ability to make engines
# compete against each other, I had trouble finding a truly simple and
# usable way to get stockfish to play itself on a mac. 
# 
# The bash-based solution here is very simple: we create a
# few named pipes and run two stockfish cli instances.
#
# We read the move from the previous player from a
# common fifo, ask for analysis, and put the result on another fifo
# for the next player to read. 
# 
# If we take ">>" to mean simply the flow of data we can summarize
# the operation as follows:
#  
#  white sf >> shared fifo >> glue.sh >> black fifo >> black sf >>
#  shared fifo >> glue.sh >> white_fifo >> white sf ...
#
#
#
#default="7k/8/R5K1/8/8/8/8/8 b - - 0 1"
default="rn1qk2r/pbppppbp/1p3np1/4P1B1/2PP4/2N2N2/PP2BPPP/R2QK2R w KQkq - 0 1"

# Delete fifos from previous stopped invocations if any, create fifos 
rm -f stock_w stock_b stock_x
mkfifo stock_w stock_b stock_x
 

cat stock_x | ./glue.sh "$default" &
pids[0]=$!
cat stock_w | stockfish > stock_x &
pids[1]=$!
cat stock_b | stockfish > stock_x &
pids[2]=$!
for pid in ${pids[*]}; do
    wait $pid
done









