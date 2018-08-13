import os
import types

{.push hint[XDeclaredButNotUsed]: off.}

proc to_string(matrix: Matrix): string =
    result = ""    
    for row in matrix:
        var output: string = ""
        for value in row:
            output = output & value & ","
        result = result & output[0 ..< output.high] & "\n"

export to_string
