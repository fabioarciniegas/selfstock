#!/bin/bash
function push_game_to_fifo(){
    exec 3> $1
    cat gamesofar >&3
    echo "" >&3
    echo "go movetime 3000" >&3
    exec 3>&-
}

function echo_to_fifo(){
    exec 3> $2
    echo $1 >&3
    exec 3>&-
}

echo -n "position fen $1 moves " > gamesofar
fenarray=($1)
turn=${fenarray[1]}
PLAYERS=("stock_w" "stock_b")
exec 4> ${PLAYERS[0]}
exec 5> ${PLAYERS[1]}
echo "[FEN \"$1\"]"
i=1
if [ $turn = "w" ]; then
   i=0
fi

echo_to_fifo "setoption name UCI_LimitStrength value true" "${PLAYERS[0]}"
echo_to_fifo "setoption name UCI_LimitStrength value true" "${PLAYERS[1]}"
echo_to_fifo "setoption name UCI_Elo value $2" "${PLAYERS[0]}"
echo_to_fifo "setoption name UCI_Elo value $3" "${PLAYERS[1]}"


push_game_to_fifo ${PLAYERS[$i]}


while read line
do
    if echo $line | grep --quiet bestmove; then
	echo $line
	let i=($i+1)%2
	result=($line)
        move=${result[1]}
#	echo -n " $move"
	printf " $move" >> gamesofar
	# If it's not the end of the game stockfish will respond
	# with a line such as bestmode a6b6 ponder b3c2
	# if no such ponder exist we assume is the end of the game
	if echo $line | grep --quiet "ponder"; then
	    push_game_to_fifo ${PLAYERS[$i]}
        else
	    if [ $i == 0 ]; then
		printf " 0-1" >> gamesofar
		echo " 0-1"
	    else
		printf " 1-0" >> gamesofar
		echo " 1-0"
	    fi
	    exec 4>&-
	    exec 5>&-	    
	    break
	fi
    fi
done
