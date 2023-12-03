app "hello-world"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br" }
    imports [
      pf.Arg,
      pf.Stdout,
      # pf.File,
      pf.Task.{Task, await},
      # pf.Path,
    ]
    provides [main] to pf

main =
    args <- Arg.list |> Task.await
    args
    |> List.get 1
    |> Result.withDefault "no item"
    |> Stdout.line
