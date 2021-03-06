#!/bin/bash
movetime=3000
if [ ! $4 == "" ]; then
    movetime=$4
fi

function push_game_to_fifo(){
    exec 3> $1
    cat gamesofar >&3
    echo "" >&3
    echo "go movetime $movetime" >&3
    exec 3>&-
}

function echo_to_fifo(){
    exec 3> $2
    echo $1 >&3
    exec 3>&-
}

echo -n "position fen $1 moves " > gamesofar
fenarray=($1)
turn=${fenarray[1]} #color to move
ply=${fenarray[5]}

PLAYERS=("stock_w" "stock_b")
exec 4> ${PLAYERS[0]}
exec 5> ${PLAYERS[1]}


date_today=$(date +%F)
echo "[Event \"selfstock\"]"
echo "[Site \"virtual\"]"
echo "[Date \"$date_today\"]"
echo "[White \"Stockfish $2\"]"
echo "[Black \"Stockfish $3\"]"
echo "[FEN \"$1\"]"
i=1
if [ $turn = "w" ]; then
   i=0
fi

echo_to_fifo "setoption name UCI_LimitStrength value true" "${PLAYERS[0]}"
echo_to_fifo "setoption name UCI_LimitStrength value true" "${PLAYERS[1]}"
echo_to_fifo "setoption name UCI_Elo value $2" "${PLAYERS[0]}"
echo_to_fifo "setoption name UCI_Elo value $3" "${PLAYERS[1]}"
#echo_to_fifo "setoption name SyzygyPath value 3-4-5" "${PLAYERS[0]}"
#echo_to_fifo "setoption name SyzygyPath value 3-4-5" "${PLAYERS[1]}"



push_game_to_fifo ${PLAYERS[$i]}

no_ponders=0
mate=0
while read line
do
    if echo $line | grep --quiet " mate "; then
	mate=1
    fi
    if echo $line | grep --quiet bestmove; then
	let i=($i+1)%2
	let ply=($ply+1)
	result=($line)
        move=${result[1]}
	echo -n " $move"
	printf " $move" >> gamesofar
	# If it's not the end of the game stockfish will respond
	# with a line such as bestmode a6b6 ponder b3c2
	# if no such ponder exist we assume is the end of the game
	if ! echo $line | grep --quiet "ponder"; then
	    let no_ponders=($no_ponders+1)
	fi
	if (($no_ponders < 2)); then
	    push_game_to_fifo ${PLAYERS[$i]}
        else
	    if [ $mate == 0 ]; then
		echo " 1/2-1/2" >> gamesofar		
		echo " 1/2-1/2"
	    elif [ $i == 0 ]; then
		echo " 1-0" >> gamesofar
		echo " 1-0"
		echo ""
		echo ""
	    else
		echo " 0-1" >> gamesofar
		echo " 0-1"
		echo ""
		echo ""
	    fi
	    exec 4>&-
	    exec 5>&-	    
	    break
	fi
    fi
done
