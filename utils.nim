import os, parsecsv, streams, strutils, times, stb_image/read

{.push hint[XDeclaredButNotUsed]: off.}

type StringMatrix = seq[seq[string]]
type ChopDirection = enum Horizontal, Vertical
type Image = object
    width*, height*, channels*: int
    data*: seq[byte]
type ImageMatrix = seq[seq[Image]]

type
    Animal* = object
      name*, species*: string
      age: int

template time(caption: string, s: stmt): expr =
    let t0 = cpuTime()
    s
    caption & ": " & $(cpuTime() - t0) & "s"

template max(a: int, b: int): expr =
    if a > b:
        a
    else:
        b

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

proc loadPng(path: string): Image =
    var image: Image
    if read.info(path, image.width, image.height, image.channels):
        image.data = read.load(path, image.width, image.height, image.channels, 0)
        result = image

proc crop(image: Image, x: int, y: int, width: int, height: int): Image =
    result.width = width
    result.height = height
    result.channels = image.channels
    result.data = newSeq[byte]()

    var r = y
    while r < height:
        var c = x
        while c < width:
            var i = 0
            while i < image.channels:
                result.data.add(image.data[(r * width * image.channels) + (c * image.channels) + i])
                inc(i)
            inc(c)
        inc(r)

proc chopImage(image: Image, direction: ChopDirection, sections: int): seq[Image] =
    result = newSeq[Image]()
    
    let width = image.width
    let height = image.height
    let section_width = width div sections
    let section_height = height div sections

    var n: cint = 0
    while n < sections:
        if direction == ChopDirection.Horizontal:
            result.add crop(image, 0, max(height - 1, n * section_height), width, max(height - 1, (n + 1) * section_height));
        else:
            result.add crop(image, max(width - 1, n * section_width), 0, max(width - 1, (n + 1) * section_width), height);
        inc(n)   

proc parsePng*(png_matrix: ImageMatrix): StringMatrix =
    result = newSeq[seq[string]]()

    for image_row in png_matrix:
        var output_row = newSeq[string]()
        for image_col in image_row:
            output_row.add $1

        result.add output_row

export StringMatrix, ImageMatrix, Image, ChopDirection
export time, matrixToString, listFiles, outputCsv, parseCsv, loadPng, chopImage
