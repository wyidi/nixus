use minijinja::{Environment, context};

fn get_flake() -> String {
    let mut path = std::path::PathBuf::from(file!());
    path.pop();
    path.push("fixtures");
    path.push("flake.nix.jinja");

    let template = String::from_utf8(std::fs::read(path).unwrap()).unwrap();
    println!("{}", template);

    let mut env = Environment::new();
    env.add_template("flake", &template).unwrap();
    let tmpl = env.get_template("flake").unwrap();

    let flake: String = tmpl.render(context!(nixus_url => format!("git+file://{}?shallow=1", env!("CARGO_MANIFEST_DIR")))).unwrap();
    println!("{}", flake);

    flake
}

#[test]
fn example() {
    let flake = get_flake();

    let tmp_dir = tempfile::tempdir().unwrap();
    println!("{}", tmp_dir.path().display());

    std::fs::write(tmp_dir.path().join("flake.nix"), flake).unwrap();

    let mut path = std::path::PathBuf::from(file!());
    path.pop();
    path.push("fixtures");
    path.push("outputs.nix");

    std::fs::copy(path, tmp_dir.path().join("outputs.nix")).unwrap();

    use std::process::Command;

    let output = Command::new("ls")
        .current_dir(tmp_dir.path())
        .output()
        .expect("Failed to start evaluation");

    println!("{}", &String::from_utf8(output.stdout).expect("API output is not valid UTF-8"));

    let output = Command::new("nix")
        .arg("flake")
        .arg("show")
        .current_dir(tmp_dir.path())
        .output()
        .expect("Failed to start evaluation");

    println!("{}", &String::from_utf8(output.stdout).expect("API output is not valid UTF-8"));
    println!("{}", &String::from_utf8(output.stderr).expect("API output is not valid UTF-8"));

    let output = Command::new("ls")
        .current_dir(tmp_dir.path())
        .output()
        .expect("Failed to start evaluation");

    println!("{}", &String::from_utf8(output.stdout).expect("API output is not valid UTF-8"));


    assert_eq!(2+3, 5);
}
