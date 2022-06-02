#!/bin/bash
function push_game_so_far_to_fifo(){
    exec 3> $1
    cat gamesofar >&3
    echo "" >&3
    echo "go movetime 3000" >&3
    exec 3>&-
}


echo -n "position fen $1 moves " > gamesofar
fenarray=($1)
turn=${fenarray[1]}
PLAYERS=("stock_w" "stock_b")
i=1
if [ $turn = "w" ]; then
   i=0
fi
push_game_so_far_to_fifo ${PLAYERS[$i]}

   
while read line
do
    if echo $line | grep --quiet bestmove; then
	echo -n "."
	let i=($i+1)%2
        MOVE=`echo $line | awk '{print substr($0,9,5)}'`
	printf "$MOVE" >> gamesofar
	push_game_so_far_to_fifo ${PLAYERS[$i]}	
    fi
done

