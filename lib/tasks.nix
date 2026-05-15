{ lib, ... }: with lib; {
    foldt = f: xs: foldl (acc: x: acc ++ f x) [] xs;

    foldts = f: xss: if xss == [] then f else foldt (x: foldts (f x) (tail xss)) (head xss);
}
