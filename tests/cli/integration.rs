mod core;

#[test]
fn plan_one_tf_node() {
    let flake = core::get_flake();

    let tmp_dir = tempfile::tempdir().unwrap();
    println!("{}", tmp_dir.path().display());

    std::fs::write(tmp_dir.path().join("flake.nix"), flake).unwrap();

    let mut path = std::path::PathBuf::from(file!());
    path.pop();
    path.push("fixtures");
    path.push("outputs01.nix");

    std::fs::copy(path, tmp_dir.path().join("outputs.nix")).unwrap();

    use std::process::Command;

    let path = std::env::current_dir().unwrap();
    std::env::set_current_dir(tmp_dir.path());
    let plan = nixus::plan();
    std::env::set_current_dir(path);

    assert_eq!(plan, nixus::Plan {
        nodes: vec![
            nixus::Node::Terraform {
                id      : String::from("Terraform.A"),
                name    : String::from("A"),
                requires: vec![],
                backend : String::from("opentofu")
            }
        ],
        order: vec![
            String::from("Terraform.A")
        ],
    });
}
