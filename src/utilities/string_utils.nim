import std/unicode

import normalize

proc removeDiacritics*(s: string): string =
  result = ""
  # Iterate over each rune in its Normalization Form D (Decomposed) representation
  for r in toNFD(s):
    # Filter out combining diacritical marks (Unicode block U+0300 to U+036F)
    let intVal = r.int
    if intVal < 0x0300 or intVal > 0x036F:
      result.add($r)

