{ lib, ... }: with lib; {
    foldt = f: xs: foldl (acc: x: acc ++ f x) [] xs;
}
