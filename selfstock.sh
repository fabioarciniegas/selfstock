#!/bin/bash
# Connect two instances of cli stockfish so they can play each other
# from a given initial position. 
#
# USAGE:
#
# ./selfstock.sh <elo white> <elo black> <FEN position>
#
# All arguments required.
#
# WARNING:
#
# This program and all related materials provided AS-IS with no warranty explicit or implied.
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
position="7k/8/R5K1/8/8/8/8/8 b - - 0 1"
#default="rn1qk2r/pbppppbp/1p3np1/4P1B1/2PP4/2N2N2/PP2BPPP/R2QK2R w KQkq - 0 1"

# Delete fifos from previous stopped invocations if any, create fifos 
rm -f stock_w stock_b stock_x
mkfifo stock_w stock_b stock_x
 
if [ ! "$3" = "" ]; then
  position=$3
fi

function ctrl_c() {
    echo "💔 ctrl-c received, killing background process engines, cleaning up fifos:"
    for pid in ${pids[*]}; do
	kill $pid
    done
    rm -f stock_w stock_b stock_x    
}

trap ctrl_c INT



cat stock_x | ./glue.sh "$position" &
pids[0]=$!
cat stock_w | stockfish > stock_x &
pids[1]=$!
cat stock_b | stockfish > stock_x &
pids[2]=$!
for pid in ${pids[*]}; do
    wait $pid
done









