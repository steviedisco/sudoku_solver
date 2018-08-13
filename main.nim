import os, parsecsv, macros, strutils
import types, csv_parser, solver, matrix_convert, stopwatch

{.push hint[XDeclaredButNotUsed]: off.}

proc list_files(dir: string, ext: string): seq[string] =
    result = newSeq[string]()

    for file in walkFiles(dir & "\\*." & ext):
        result.add(file)

proc output_csv(output_dir: string, input_file: string, content: string) =
    var (input_dir, input_name, input_ext) = splitFile(input_file)
    
    let module = open(output_dir & "\\" & input_name & ".csv", fmWrite)
    module.write(content)
    module.close

proc process_csv(csv: string, output_dir: string) =
    var known = csv_parser.parse(csv)
    var solution = solver.solve(known)
    output_csv(output_dir, csv, matrix_convert.to_string(solution))

proc process_png(csv: string, output_dir: string) =
    var known = csv_parser.parse(csv)
    var solution = solver.solve(known)
    output_csv(output_dir, csv, matrix_convert.to_string(solution))

proc process(input_dir: string, output_dir: string, ext: string) =
    var inputs = list_files(input_dir, ext)

    for input in inputs:
        if ext == "csv":
            echo time(input, process_csv(input, output_dir)) 
        else:
            echo time(input, process_png(input, output_dir)) 

proc main() =
    var input_dir = paramStr(1)
    var output_dir = paramStr(2)
    echo time("All CSVs", process(input_dir, output_dir, "csv"))
    echo time("All PNGs", process(input_dir, output_dir, "png"))

echo time("Total", main())
