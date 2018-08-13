import os, parsecsv, streams, strutils, times, stb_image/read

{.push hint[XDeclaredButNotUsed]: off.}

type StringMatrix = seq[seq[string]]
type ImageMatrix = seq[seq[ptr FIBITMAP]]
type ChopDirection = enum Horizontal, Vertical

template time(caption: string, s: stmt): expr =
    let t0 = cpuTime()
    s
    caption & ": " & $(cpuTime() - t0) & "s"

proc matrixToString*(matrix: StringMatrix): string =
    result = ""    
    for row in matrix:
        var output: string = ""
        for value in row:
            output = output & value & ","
        result = result & output[0 ..< output.high] & "\n"

proc listFiles*(dir: string, ext: string): seq[string] =
    result = newSeq[string]()

    for file in walkFiles(dir & "\\*." & ext):
        result.add(file)

proc outputCsv*(output_dir: string, input_file: string, content: string) =
    var (input_dir, input_name, input_ext) = splitFile(input_file)
    
    let module = open(output_dir & "\\" & input_name & ".csv", fmWrite)
    module.write(content)
    module.close

proc parseCsv*(path: string): StringMatrix =
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

proc loadPng(path: string): ptr FIBITMAP =
    result = FreeImage_Load(FREE_IMAGE_FORMAT.FIF_PNG, path, 0)

proc chopImage(image: ptr FIBITMAP, direction: ChopDirection, num_sections: int): seq[ptr FIBITMAP] =
    result = newSeq[ptr FIBITMAP]()
    
    let width = cast[cint](FreeImage_GetWidth(image))
    let height =cast[cint](FreeImage_GetHeight(image))
    let section_width = cast[cint](width div num_sections)
    let section_height = cast[cint](height div num_sections)

    var n: cint = 0
    while n < num_sections:
        if direction == ChopDirection.Horizontal:
            result.add FreeImage_Copy(image, 0, n * section_height, width, (n + 1) * section_height);
        else:
            result.add FreeImage_Copy(image, n * section_width, 0, (n + 1) * section_width, height);
        inc(n)   

proc parsePng*(png_matrix: ImageMatrix): StringMatrix =
    result = newSeq[seq[string]]()

    for image_row in png_matrix:
        var output_row = newSeq[string]()
        for image_col in image_row:
            output_row.add $1

        result.add output_row

export StringMatrix, ImageMatrix, ChopDirection
export time, matrixToString, listFiles, outputCsv, parseCsv, loadPng, chopImage
