# sudoku_solver
fairly light sudoku solver for monthly code compo for csv and png input/output types

install nim
https://nim-lang.org/install_windows.html

to build, you'll need to nim-freeimage. 
it's a bit outdated so you'll need to massage it -

1. clone github/nim-freeimage
2. rename nim-freeimage.babel to freeimage.nimble
3. edit nimble file to reflect this
4. run nimble install

FYI
VS Code has a nice nim plugin
GDB is good for debugging in the terminal