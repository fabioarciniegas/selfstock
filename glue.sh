#!/bin/bash
function push_game_to_fifo(){
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
exec 4> ${PLAYERS[0]}
exec 5> ${PLAYERS[1]}
echo "[FEN \"$1\"]"
i=1
if [ $turn = "w" ]; then
   i=0
fi
push_game_to_fifo ${PLAYERS[$i]}
game_on=1



while read line
do
    if echo $line | grep --quiet bestmove; then
	let i=($i+1)%2
	result=($line)
        move=${result[1]}
	echo -n " $move"
	printf " $move" >> gamesofar
	# If it's not the end of the game stockfish will respond
	# with a line such as bestmode a6b6 ponder b3c2
	# if no such ponder exist we assume is the end of the game
	if echo $line | grep --quiet "ponder"; then
	    push_game_to_fifo ${PLAYERS[$i]}
	else
	    exec 4>&-
	    exec 5>&-	    
	    break
	fi
    fi
done
