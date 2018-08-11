import os, parsecsv, streams
import types

{.push hint[XDeclaredButNotUsed]: off.}

proc parse(path: string): matrix =
    var stream = newFileStream(path, fmRead)
    if stream == nil: 
        quit("cannot open the file" & path)

    var parser: CsvParser
    open(parser, stream, path)

    result = newSeq[seq[string]]()

    while readRow(parser):
        var row: seq[string] = newSeq[string]()
        for value in items(parser.row):
            row.add(value)
        
        result.add(row)

    close(parser)

export parse