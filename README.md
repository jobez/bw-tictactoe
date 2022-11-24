# bw-tictactoe

This is an implementation of the legendary game of tictactoe in cairo. I encoded the representation of the tictactoe representation in a felt, where each position on the board is (0 through 7) is represented as that position to the power of two.

This means that winning states in the board can be represented in binary and that binary can be represented as a felt.

```cairo
 let winners = [
   448, // 111 000 000
   56, // 000 111 000
   7, // 000 000 111
   292, // 100 100 100
   146, // 010 010 010
   73, // 001 001 001
   273, // 100 010 001
   84, // 001010100  
 ];
```

We check if a player's board state makes the game 'whole' by doing `bitwise_and` against the given player state representation.

See this blogpost where I have a demo UI against this contract. It is still a draft and I have yet to deploy to testnet:

https://jobez.github.io/internet-computer-land/posts/1_tictactoe/
