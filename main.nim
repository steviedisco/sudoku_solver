import os
import utils, solver 

{.push hint[XDeclaredButNotUsed]: off.}

proc processCsv*(csv: string, output_dir: string) =
    var known = utils.parseCsv(csv)
    var solution = solver.solve(known)
    outputCsv(output_dir, csv, utils.matrixToString(solution))

proc processPng*(csv: string, output_dir: string) =
    var image = utils.loadPng(csv)

    var png_matrix = newSeq[seq[Image]]()
    var rows = utils.chopImage(image, ChopDirection.Horizontal, 9)

    for r in rows:
        png_matrix.add utils.chopImage(r, ChopDirection.Vertical, 9)

    var known = utils.parseImageMatrix(png_matrix)
    var solution = solver.solve(known)
    outputCsv(output_dir, csv, utils.matrixToString(solution))

proc process*(input_dir: string, output_dir: string, ext: string) =
    var inputs = listFiles(input_dir, ext)

    for input in inputs:
        if ext == "csv":
            echo time(input, processCsv(input, output_dir)) 
        else:
            echo time(input, processPng(input, output_dir)) 

proc main*() =
    var input_dir = paramStr(1)
    var output_dir = paramStr(2)
    echo time("csv", process(input_dir, output_dir, "csv"))
    echo time("png", process(input_dir, output_dir, "png"))

echo time("all", main())