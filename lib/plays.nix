{ lib, ... }: with lib; {
    # Assumption: 
    # - All values except tasks are equal between plays (f x)
    # - "f" is a function that ranges over plays
    # - "xs" is a list of arguments of f
    foldp = f: xs: foldl ( acc: x: 
      { tasks = acc.tasks ++ (foldl ( acc: x: 
        { tasks = acc.tasks ++ x.tasks; } 
      )  { tasks = []; } (f x)).tasks;}
    ) { tasks = []; } xs |> singleton;

    stackp = f: xs: foldl (acc: x: acc ++ (f x)) [] xs;
}
