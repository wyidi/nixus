{ lib, ... }: with lib; rec {
    stackt  = f: xs: foldl (acc: x: acc ++ (f x)) [] xs;

    stackt' = f: xss: if xss == [] then [] else stackt (x: stackt' (f x) (tail xss)) (head xss);
}
