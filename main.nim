import os, parsecsv, macros, strutils
import types, csv_parser, solver, matrix_convert

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

proc csv_solve(input_dir: string, output_dir: string) =
    var csv_inputs = list_files(input_dir, "csv")

    for csv in csv_inputs:
        var known = csv_parser.parse(csv)
        var solution = solver.solve(known)
        output_csv(output_dir, csv, matrix_convert.to_string(solution))

proc main() =
    var input_dir = paramStr(1)
    var output_dir = paramStr(2)

    csv_solve(input_dir, output_dir)

main()