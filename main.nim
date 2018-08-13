import os, parsecsv
import types, parser, solver, matrix_convert

var path = paramStr(1) # "C:\\Development\\suduko_solver\\inputs\\sudoku1.csv"
var known = parser.parse(path)
var solution = solver.solve(known)

echo matrix_convert.to_string(solution)