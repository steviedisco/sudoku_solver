import os, parsecsv
import types, parser, solver, output_to_text

var path = "C:\\Development\\suduko_solver\\inputs\\sudoku1.csv" # paramStr(1) # 
var known = parser.parse(path)
var solution = solver.solve(known)

output_to_text.write(solution)