import os, parsecsv, streams, strutils, times, stb_image/read, stb_image/write

{.push hint[XDeclaredButNotUsed]: off.}

var png_test: int = 1
let png_test_dir: string = "C:\\Users\\steve\\Documents\\"

## ocrad stuff
type OCRAD_ErrNo = enum 
    OCRAD_ok = 0
    OCRAD_bad_argument
    OCRAD_mem_error
    OCRAD_sequence_error
    OCRAD_library_error

type OCRAD_Pixmap_Mode = enum 
    OCRAD_bitmap
    OCRAD_greymap
    OCRAD_colormap

type OCRAD_Descriptor* = ref object

type OCRAD_Pixmap* = ref object
    data*: ptr array[100000, cuchar]
    height*: cint
    width*: cint
    mode*: OCRAD_Pixmap_Mode    

var buffer: array[100000, cuchar]

const ocrad_dll* = "ocrad.dll"
proc OCRAD_version*(): cstring {.cdecl, stdcall, importc, dynlib: ocrad_dll.}
proc OCRAD_open*(): OCRAD_Descriptor {.cdecl, stdcall, importc, dynlib: ocrad_dll.}
proc OCRAD_close*(ocrdes: OCRAD_Descriptor) {.cdecl, stdcall, importc, dynlib: ocrad_dll.}
proc OCRAD_get_errno*(ocrdes: OCRAD_Descriptor): OCRAD_ErrNo {.cdecl, stdcall, importc, dynlib: ocrad_dll.}
proc OCRAD_set_image*(ocrdes: OCRAD_Descriptor, pixmap: OCRAD_Pixmap, invert: bool): cint {.cdecl, stdcall, importc, dynlib: ocrad_dll.}
proc OCRAD_recognize*(ocrdes: OCRAD_Descriptor, layout: bool): cint {.cdecl, stdcall, importc, dynlib: ocrad_dll.}
proc OCRAD_result_first_character*(ocrdes: OCRAD_Descriptor): cint {.cdecl, stdcall, importc, dynlib: ocrad_dll.}

##
type StringMatrix* = seq[seq[string]]
type ChopDirection* = enum Horizontal, Vertical

type Image* = ref object
    width*, height*, channels*: int
    data*: seq[byte]

type ImageMatrix* = seq[seq[Image]]

template time*(caption: string, s: stmt): expr =
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

proc loadPng*(path: string): Image =
    var image: Image
    new image
    if read.info(path, image.width, image.height, image.channels):
        image.data = read.load(path, image.width, image.height, image.channels, 0)
        result = image

proc savePng*(image: Image, path: string) =
    if not write.writePNG(path, image.width, image.height, image.channels, image.data):
        quit("failed to save png")

proc crop*(image: Image, x: int, y: int, width: int, height: int): Image =
    new result
    result.width = width
    result.height = height
    result.channels = image.channels
    result.data = newSeq[byte]()

    var r = y
    while r < y + height:
        var c = x
        while c < x + width:
            var i = 0
            while i < image.channels:
                result.data.add(image.data[(r * image.width * image.channels) + (c * image.channels) + i])
                inc(i)
            inc(c)
        inc(r)

    savePng(result, png_test_dir & $png_test & ".png")
    inc png_test

proc chopImage*(image: Image, direction: ChopDirection, sections: int): seq[Image] =
    result = newSeq[Image]()
    
    let width = image.width
    let height = image.height
    let section_width = width div sections
    let section_height = height div sections

    var n: cint = 0
    while n < sections:
        if direction == ChopDirection.Horizontal:
            result.add crop(image, 0, (n * section_height) + 7, width, section_height - 14)
        else:
            result.add crop(image, (n * section_width) + 10, 0, section_width - 20, height)
        inc(n)   

proc getOcradPixmap(image: Image): OCRAD_Pixmap =
    new result
    result.mode = OCRAD_Pixmap_Mode.OCRAD_colormap
    result.height = image.height.cint
    result.width = image.width.cint
    result.data = buffer.unsafeAddr

    var count: int = 0
    for byt in image.data:
        buffer[count] = byt.cuchar
        inc count

proc parseImage*(ocrdes: OCRAD_Descriptor, image: Image): string =
    var pixmap = getOcradPixmap(image)

    if OCRAD_set_image(ocrdes, pixmap, false) == -1:
        quit("Ocrad failed to set image")

    if OCRAD_recognize(ocrdes, false) == -1:
        quit("Ocrad failed to recognize image")

    var value = OCRAD_result_first_character(ocrdes).byte
    if value != 0 and Digits.find(value.cuchar) >= 0:
        result = $value.cuchar
    else:
        result = " "

proc parseImageMatrix*(png_matrix: ImageMatrix): StringMatrix =
    result = newSeq[seq[string]]()

    var ocrdes = OCRAD_open()

    if OCRAD_get_errno(ocrdes) != OCRAD_ErrNo.OCRAD_ok: 
        quit("Ocrad failed to initialise")

    for image_row in png_matrix:
        var output_row = newSeq[string]()

        for image in image_row:
            output_row.add parseImage(ocrdes, image)

        result.add output_row

    OCRAD_close(ocrdes)