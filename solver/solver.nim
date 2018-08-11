import strutils
import types

proc square*(i: cint; j: cint): cint
proc set_cell*(i: cint; j: cint; n: cint)
proc clear_cell*(i: cint; j: cint): cint
proc init_known*(matrix: Matrix)
proc is_available*(i: cint; j: cint; n: cint): bool
proc advance_cell*(i: cint; j: cint): bool
proc algorithm*()
proc init_bits*()
proc solve*(matrix: Matrix): Matrix

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

#[
proc main*(argc: cint; argv: cstringArray): cint =
  init_bits()
  init_known(argc - 1, argv + 1)
  solve_sudoku()
  print_matrix()
  return EXIT_SUCCESS
]#

proc solve*(matrix: Matrix): Matrix =
  init_bits()
  init_known(matrix)
  algorithm() 

##  Returns the index of the square the cell (i, j) belongs to.
proc square*(i: cint; j: cint): cint =
  return (i div 3) * 3 + j div 3

##  Stores the number n in the cell (i, j), and turns on the corresponding
## bits in rows, cols, and squares.
proc set_cell*(i: cint; j: cint; n: cint) =
  matrix[i][j] = n
  rows[i] = rows[i] or bits[n]
  cols[j] = cols[j] or bits[n]
  squares[square(i, j)] = squares[square(i, j)] or bits[n]

##  Clears the cell (i, j) and turns off the corresponding bits in rows, cols,
## and squares. Returns the number it contained.
proc clear_cell*(i: cint; j: cint): cint =
  var n: cint = matrix[i][j]
  matrix[i][j] = 0
  rows[i] = rows[i] and not bits[n]
  cols[j] = cols[j] and not bits[n]
  squares[square(i, j)] = squares[square(i, j)] and not bits[n]
  return n

##  Processes the program arguments. Each argument is assumed to be a string
## with three digits row-col-number, 1-based, representing the known cells in the
## Sudoku. For example, "123" means there is a 3 in the cell (0, 1).
proc init_known*(matrix: Matrix) =
  var row_count: cint = 0
  for row in matrix:
    inc(row_count)

    var col_count: cint = 0
    for value in row:
      inc(col_count)

      if not value.contains AllChars - Digits:
        set_cell(row_count - 1, col_count - 1, cast[cint](parseInt(value)))
        known[row_count - 1][col_count - 1] = 1
    
##  Can we put n in the cell (i, j)?
proc is_available*(i: cint; j: cint; n: cint): bool =
  return (rows[i] and bits[n]) == 0 and (cols[j] and bits[n]) == 0 and
      (squares[square(i, j)] and bits[n]) == 0

##  Tries to fill the cell (i, j) with the next available number.
## Returns a flag to indicate if it succeeded.
proc advance_cell*(i: cint; j: cint): bool =
  var n: cint = clear_cell(i, j)
  while n <= 9:
    inc(n)
    if is_available(i, j, n):
      set_cell(i, j, n)
      return true
  return false

##  The main function, a fairly generic backtracking algorithm.
proc algorithm*() =
  var pos: cint = 0
  while true:
    while pos < 81 and known[pos div 9][pos mod 9] > 0:
      inc(pos)
    if pos >= 81:
      break
    if advance_cell(pos div 9, pos mod 9):
      inc(pos)
    else:
      while true:
        dec(pos)
        if not (pos >= 0 and known[pos div 9][pos mod 9] > 0): break
      if pos < 0:
        break

##  Initializes the array with powers of 2.
proc init_bits*() =
  var one: cint = 1
  var n: cint = one
  while n < 10:
    bits[n] = one shl n
    inc(n)

##  Prints the matrix using some ANSI escape sequences
## to distinguish the originally known numbers.
proc print_matrix*() =
  var i: cint = 0
  while i < 9:
    if (i mod 3) == 0:
      print_separator()
    var j: cint = 0
    while j < 9:
      var cell: cint = matrix[i][j]
      if (j mod 3) == 0:
        printf("e[1;34m|e[0m ")
      else:
        printf(" ")
      if known[i][j]:
        printf("e[1;34m%de[0m ", cell)
      else:
        printf("%d ", cell)
      inc(j)
    printf("|\x0A")
    inc(i)
  print_separator()

##  Utility to print lines and crosses, used by print_matrix.
proc print_separator*() =
  var i: cint = 0
  while i < 3:
    printf("e[1;34m+---------e[0m")
    inc(i)
  printf("e[1;34m+\x0Ae[0m")

export solve