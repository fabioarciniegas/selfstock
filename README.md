# selfstock

Quickly play stockfish against itself from the command line:

```
./selfstock.sh <elo white> <elo black> <FEN position>

```

Produces a game in pgn format, importable in any analysis tool including lichess.

## WARNING:

This program and all related materials provided AS-IS with no warranty explicit or implied.

## Where to get a FEN position?

An easy place is https://lichess.org/editor

You can copy the FEN string at the bottom the interface and pass it as a parameter to selfstock:

[lichess_editor.png]

## Example:

```
./selfstock.sh 1800 2000 "3q2k1/3p1pbp/2n1pnp1/8/3P4/2P1BN2/PPQ1P2P/2R1K2P w - - 0 1"
```

Notice the quotes around the FEN.






## Background
Although several chess programs offer the ability to make engines compete against each other, I had trouble finding a truly simple and scriptable way to get stockfish to play itself on a mac. 


## Implementation
The bash-based solution here is very simple: we create a few named pipes and run two stockfish cli instances.

We read the move from the previous player from a common fifo, ask for analysis, and put the result on another fifo
for the next player to read. If we take ">>" to mean simply the flow of data we can summarize the operation as follows:

``
  white sf >> shared fifo >> glue.sh >> black fifo >> black sf >> shared fifo >> glue.sh >> white_fifo >> white sf ...
``

# Notes on particluarly long games

As you may see, games are often longer than human counterparts. An extreme component of this is stockfish always trying to exhaust possibilities rather than relying on "well-known" heuristics. For example, this end game:


Please note that stockfish is always doing its best to find a

https://chess.stackexchange.com/questions/663/is-it-a-draw-by-insufficient-material-if-the-board-is-k-vs-k-n-n 
https://syzygy-tables.info/metrics
