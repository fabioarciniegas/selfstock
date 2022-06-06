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


https://www.shredderchess.com/download/div/uci.zip

## Implementation
The bash-based solution here is very simple: we create a few named pipes and run two stockfish cli instances.

We read the move from the previous player from a common fifo, ask for analysis, and put the result on another fifo
for the next player to read. If we take ">>" to mean simply the flow of data we can summarize the operation as follows:

``
  white sf >> shared fifo >> glue.sh >> black fifo >> black sf >> shared fifo >> glue.sh >> white_fifo >> white sf ...
``

# Notes on particluarly long games

As you may see, games are often longer than human counterparts. An extreme component of this is stockfish always trying to exhaust possibilities rather than relying on "well-known" heuristics. For example, this end game:


./selfstock.sh 3000 2000 "6k1/8/6KP/8/8/8/8/8 b - - 0 1"


~/selfstock ./selfstock.sh 3000 2000 "6k1/8/6KP/8/8/8/8/8 b - - 0 1"
[FEN "6k1/8/6KP/8/8/8/8/8 b - - 0 1"]
 g8h8 g6f5 h8g8 f5f6 g8h7 f6f5 h7g8 f5e4 g8f7 e4f4 f7f6 f4e4 f6g6 e4d4 g6f7 d4c4 f7f8 c4d4 f8g8 d4e3 g8f8 e3f2 f8f7 h6h7 f7g7 f2g2 g7h7 g2h1 h7g8 h1g1 g8f7 g1f2 f7g6 f2g3 g6f5 g3h3 f5f4 h3h2 f4f5 h2g1 f5f4 g1h2 f4g5 h2h3 g5f5 h3h4 f5e6 h4g5 e6d6 g5f5 d6c7 f5e4 c7b6 e4d4 b6a5 d4c5 a5a6 c5d5 a6b6 d5c4 b6c6 c4d4 c6d7 d4c5 d7d8 c5c4 d8e7 c4b4 e7d7 b4c3 d7d8 c3c2 d8d7 c2d1 d7d6 d1e2 d6d5 e2f2 d5e5 f2f3 e5d6 f3g4 d6c5 g4h4 c5b5 h4g3 b5c5 g3f4 c5b5 f4e5 b5a5 e5f5 a5a6 f5e5 a6b5 e5d6 b5a5 d6c6 a5a4 c6b6 a4a3 b6c7 a3b3 c7b7 b3a4 b7c7 a4b5 c7b7 b5c5 b7c7 c5b4 c7d6 b4c4 d6e6 c4d4 e6f5 d4d5 f5f4 d5d6 f4g3 d6c7 g3g2 c7b7 g2g1 b7b6 g1h2 b6a6 h2g3 a6a7 g3f3 1/2-1/2

~/selfstock ./selfstock.sh 100 2000 "6k1/8/6KP/8/8/8/8/8 b - - 0 1"
[FEN "6k1/8/6KP/8/8/8/8/8 b - - 0 1"]
 g8h8 g6f5 h8h7 f5e6 h7g6 e6e5 g6h6 e5f5 h6h7 f5g5 h7h8 g5f5 h8g8 f5f4 g8g7 f4e3 g7g8 e3e4 g8f8 e4f3 f8g7 f3g2 g7f7 g2h3 f7e7 h3g4 e7d7 g4h4 d7d8 h4g4 d8c7 g4f4 c7b7 f4f5 b7a7 f5g5 a7b8 g5f5 b8b7 f5g6 b7b6 g6f6 b6c6 f6g6 c6d6 g6h5 d6c5 h5h4 c5b6 h4g5 b6c5 g5g6 c5d6 g6f5 d6c6 f5g4 c6d7 g4f4 d7e6 f4g4 e6d7 g4h3 d7e8 h3g3 e8d8 g3f2 d8c8 f2e3 c8b8 e3f4 b8b7 f4f5 b7b6 f5f4 b6b7 f4f5 b7c7 f5g5 c7d7 g5h4 d7e6 h4g4 e6e7 g4g3 e7f7 g3h3 f7e8 h3h2 e8f8 h2h3 f8f7 h3g4 f7f6 g4f3 f6g7 f3g3 g7f7 g3g2 f7f8 g2f2 f8e8 f2g1 e8e7 g1h1 e7d7 h1h2 d7c7 h2g3 c7b7 g3f3 1/2-1/2

Please note that stockfish is always doing its best to find a

https://chess.stackexchange.com/questions/663/is-it-a-draw-by-insufficient-material-if-the-board-is-k-vs-k-n-n 
https://syzygy-tables.info/metrics
