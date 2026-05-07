{ lib, ... }: with lib; {
    # Assumption: 
    # - All values except tasks are equal between plays (f x)
    # - "f" is a function that ranges over plays
    # - "xs" is a list of arguments of f
    foldp = f: xs: (xs |> head |> f) // foldl ( acc: x: { tasks = acc.tasks ++ (f x).tasks; } ) { tasks = []; } xs;
}
