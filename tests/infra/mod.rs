use minijinja::{Environment, context};

pub fn get_flake() -> String {
    let mut path = std::path::PathBuf::from(file!());
    path.pop();
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
