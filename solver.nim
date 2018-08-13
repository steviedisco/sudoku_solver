import strutils
import utils

proc square*(i: cint; j: cint): cint
proc setCell*(i: cint; j: cint; n: cint)
proc clearCell*(i: cint; j: cint): cint
proc initKnown*(matrix: StringMatrix)
proc isAvailable*(i: cint; j: cint; n: cint): bool
proc advanceCell*(i: cint; j: cint): bool
proc initBits*()
proc solve*(matrix: StringMatrix): StringMatrix
proc algorithm*(): StringMatrix
proc arrayToMatrix*(): StringMatrix

##  The Sudoku matrix itself.
var matrix*: array[9, array[9, cint]]

##  Which numbers were given as known in the problem.
var known*: array[9, array[9, cint]]

##  An array of nine integers, each of which representing a sub-square.
## Each integer has its nth-bit on iff n belongs to the corresponding sub-square.
var squares*: array[9, cint]

##  An array of nine integers, each of which representing a row.
## Each integer has its nth-bit on iff n belongs to the corresponding row.
var rows*: array[9, cint]

##  An array of nine integers, each of which representing a column.
## Each integer has its nth-bit on iff n belongs to the corresponding column.
var cols*: array[9, cint]

##  An array with some powers of 2 to avoid shifting all the time.
var bits*: array[10, cint]

proc solve*(matrix: StringMatrix): StringMatrix =
  initBits()
  initKnown(matrix)
  result = algorithm() 

##  Returns the index of the square the cell (i, j) belongs to.
proc square*(i: cint; j: cint): cint =
  return (i div 3) * 3 + j div 3

## Stores the number n in the cell (i, j), and turns on the corresponding
## bits in rows, cols, and squares.
proc setCell*(i: cint; j: cint; n: cint) =
  matrix[i][j] = n
  rows[i] = rows[i] or bits[n]
  cols[j] = cols[j] or bits[n]
  squares[square(i, j)] = squares[square(i, j)] or bits[n]

##  Clears the cell (i, j) and turns off the corresponding bits in rows, cols,
## and squares. Returns the number it contained.
proc clearCell*(i: cint; j: cint): cint =
  var n: cint = matrix[i][j]
  matrix[i][j] = 0
  rows[i] = rows[i] and not bits[n]
  cols[j] = cols[j] and not bits[n]
  squares[square(i, j)] = squares[square(i, j)] and not bits[n]
  return n

##  Processes the program arguments. Each argument is assumed to be a string
## with three digits row-col-number, 1-based, representing the known cells in the
## Sudoku. For example, "123" means there is a 3 in the cell (0, 1).
proc initKnown*(matrix: StringMatrix) =
  var row_count: cint = 0
  for row in matrix:
    inc(row_count)

    var col_count: cint = 0
    for value in row:
      inc(col_count)
      
      if value.find(Digits) >= 0:
        setCell(row_count - 1, col_count - 1, cast[cint](parseInt(value)))
        known[row_count - 1][col_count - 1] = 1
    
##  Can we put n in the cell (i, j)?
proc isAvailable*(i: cint; j: cint; n: cint): bool =
  return (rows[i] and bits[n]) == 0 and (cols[j] and bits[n]) == 0 and (squares[square(i, j)] and bits[n]) == 0

##  Tries to fill the cell (i, j) with the next available number.
## Returns a flag to indicate if it succeeded.
proc advanceCell*(i: cint; j: cint): bool =
  var n: cint = clearCell(i, j)  
  inc(n)
  while n <= 9:
    if isAvailable(i, j, n):
      setCell(i, j, n)
      return true
    inc(n)
  return false

##  The main function, a fairly generic backtracking algorithm.
proc algorithm*(): StringMatrix =
  var pos: cint = 0

  while true:
    while pos < 81 and known[pos div 9][pos mod 9] > 0:
      inc(pos)
    if pos >= 81:
      break
    if advanceCell(pos div 9, pos mod 9):
      inc(pos)
    else:
      while true:
        dec(pos)
        if not (pos >= 0 and known[pos div 9][pos mod 9] > 0): break
      if pos < 0:
        break

  result = arrayToMatrix()

##  Initializes the array with powers of 2.
proc initBits*() =
  var 
    one: cint = 1
    n: cint = 1

  while n < 10:
    bits[n] = one shl n
    inc(n)

proc arrayToMatrix*(): StringMatrix =
  var i: cint = 0
  result = newSeq[seq[string]]()
  while i < 9:
    var j: cint = 0
    var row = newSeq[string]()
    while j < 9:
      row.add($matrix[i][j])
      inc(j)
    result.add(row)
    inc(i)

export solve