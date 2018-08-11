import os, parsecsv, streams

var path = paramStr(1) # "C:\\Development\\suduko_solver\\inputs\\sudoku1.csv"

var stream = newFileStream(path, fmRead)
if stream == nil: 
    quit("cannot open the file" & path)

var parser: CsvParser
open(parser, stream, path)

while readRow(parser):
    var row: string = ""
    for value in items(parser.row):
        row = row & value & ","
    echo row[0 ..< row.high]

close(parser)