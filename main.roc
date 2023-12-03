app "aoc01"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br" }
    imports [
      pf.Arg,
      pf.Stdout,
      pf.Stderr,
      pf.File,
      pf.Task.{Task, await},
      pf.Path,
    ]
    provides [main] to pf

translateNum = \line ->
    Str.replaceEach line "one" "1"
      |> Str.replaceEach "two" "2"
      |> Str.replaceEach "three" "3"
      |> Str.replaceEach "four" "4"
      |> Str.replaceEach "five" "5"
      |> Str.replaceEach "six" "6"
      |> Str.replaceEach "seven" "7"
      |> Str.replaceEach "eight" "8"
      |> Str.replaceEach "nine" "9"

interpretLine = \line ->
    line
      |> Str.trim
      |> Str.graphemes
      |> List.walk "" \acc, c ->
        translateNum(Str.concat acc c)

parseLine = \line ->
    line
      |> Str.trim
      |> Str.graphemes
      |> List.keepIf (\c -> when c is
        "0" -> Bool.true
        "1" -> Bool.true
        "2" -> Bool.true
        "3" -> Bool.true
        "4" -> Bool.true
        "5" -> Bool.true
        "6" -> Bool.true
        "7" -> Bool.true
        "8" -> Bool.true
        "9" -> Bool.true
        _ -> Bool.false
      )

calibrationValue = \digits ->
    first = List.first digits
      |> Result.try Str.toI32
      |> Result.map \c -> c * 10

    second = List.last digits
      |> Result.try Str.toI32
      |> Result.map \c -> c

    when (first, second) is
    (Ok a, Ok b) -> Ok (a + b)
    _ -> Err "line entry missing digits"

main =
    args <- Arg.list |> Task.await
    path = args
      |> List.get 1
      |> Result.withDefault "no item"
      |> Path.fromStr

    task =
        contents <- File.readUtf8 path |> await
        lines = Str.trim contents
          |> Str.split "\n"
          |> List.map interpretLine
          |> List.map parseLine
          |> List.map calibrationValue
          |> List.keepIf Result.isOk
          |> List.map \v -> Result.withDefault v 0
          |> List.walk 0 Num.add

        dbg lines
        Stdout.line "foobar"

    Task.attempt task \result ->
        when result is
        Ok {} -> Task.ok {}
        Err err ->
          msg =
              when err is
                  FileWriteErr _ PermissionDenied -> "PermissionDenied"
                  FileWriteErr _ Unsupported -> "Unsupported"
                  FileWriteErr _ (Unrecognized _ other) -> other
                  FileReadErr _ _ -> "Error reading file"
                  _ -> "Uh oh, there was an error!"

          {} <- Stderr.line msg |> await

          Task.err 1 # 1 is an exit code to indicate failure