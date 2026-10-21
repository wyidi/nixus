#[test]
fn example() {
    let flake = super::common::get_flake();

    let tmp_dir = tempfile::tempdir().unwrap();
    println!("{}", tmp_dir.path().display());

    std::fs::write(tmp_dir.path().join("flake.nix"), flake).unwrap();

    let mut path = std::path::PathBuf::from(file!());
    path.pop();
    path.push("fixtures");
    path.push("outputs.nix");

    std::fs::copy(path, tmp_dir.path().join("outputs.nix")).unwrap();

    use std::process::Command;

    let path = std::env::current_dir().unwrap();
    std::env::set_current_dir(tmp_dir.path());
    let plan = nixus::toposort();
    std::env::set_current_dir(path);

    assert_eq!(plan, nixus::Plan {
        nodes: vec![ 
            nixus::Node::Terraform {
                id: "Terraform.ProxmoxVM.example".to_string(), 
                name: "ProxmoxVM.example".to_string(), 
                requires: vec![],
                backend: "opentofu".to_string()
            }
        ],
        order: vec![
            "Terraform.ProxmoxVM.example".to_string()
        ],
    });
}
