# selfstock

A pure bash solution to play stockfish against itself using only the cli.

```
./selfstock.sh <elo white> <elo black> <FEN position>

```
Will produce a game in pgn format, importable in any GUI including lichess.

Example:

```
./selfstock.sh 1800 2000 "rn1qk2r/pbppppbp/1p3np1/4P1B1/2PP4/2N2N2/PP2BPPP/R2QK2R w KQkq - 0 1"
```

## Background
Although several chess programs offer the ability to make engines compete against each other, I had trouble finding a truly simple and scriptable way to get stockfish to play itself on a mac. 


## Implementation
The bash-based solution here is very simple: we create a few named pipes and run two stockfish cli instances.

We read the move from the previous player from a common fifo, ask for analysis, and put the result on another fifo
for the next player to read. If we take ">>" to mean simply the flow of data we can summarize the operation as follows:

``
  white sf >> shared fifo >> glue.sh >> black fifo >> black sf >> shared fifo >> glue.sh >> white_fifo >> white sf ...
``
