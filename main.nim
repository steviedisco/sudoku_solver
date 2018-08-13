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

proc solve_csv(csv: string, output_dir: string) =
    var known = csv_parser.parse(csv)
    var solution = solver.solve(known)
    output_csv(output_dir, csv, matrix_convert.to_string(solution))

proc process_csvs(input_dir: string, output_dir: string) =
    var csv_inputs = list_files(input_dir, "csv")

    for csv in csv_inputs:
        echo time(csv, solve_csv(csv, output_dir))

proc main() =
    var input_dir = paramStr(1)
    var output_dir = paramStr(2)

    echo time("All CSVs", process_csvs(input_dir, output_dir))

echo time("Total", main())
