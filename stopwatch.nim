import times, os

{.push hint[XDeclaredButNotUsed]: off.}

template time(caption: string, s: stmt): expr =
  let t0 = cpuTime()
  s
  caption & ": " & $(cpuTime() - t0) & "s"

export time