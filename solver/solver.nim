import os, parsecsv
import types, parser, output_to_text

proc solve(values: types.matrix): types.matrix =
    result = values

var path = "C:\\Development\\suduko_solver\\inputs\\sudoku1.csv" # paramStr(1) # 
var values = parser.parse(path)
var solution = solve(values)

output_to_text.write(solution)


