REM debug
nim c --lineDir:on --debuginfo main.nim 

REM release
REM nim c -r -o:sudoku_solver.exe --verbosity:0 main.nim