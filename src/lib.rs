use serde::Deserialize;

#[derive(Deserialize, Debug, PartialEq, Eq)]
#[serde(tag = "type")]
pub enum Node {
    Terraform { id: String, name: String, requires: Vec<String>, backend: String },
    NixOS     { id: String, name: String, requires: Vec<String>, },
    Ansible   { id: String, name: String, requires: Vec<String>, },
    Service   { id: String, name: String, requires: Vec<String>, },
}

impl Node {
    pub fn id(&self) -> &str {
        match self {
            Node::Terraform { id, .. } => id,
            Node::NixOS     { id, .. } => id,
            Node::Ansible   { id, .. } => id,
            Node::Service   { id, .. } => id,
        }
    }

    pub fn name(&self) -> &str {
        match self {
            Node::Terraform { name, .. } => name,
            Node::NixOS     { name, .. } => name,
            Node::Ansible   { name, .. } => name,
            Node::Service   { name, .. } => name,
        }
    }


    pub fn requires(&self) -> &Vec<String> {
        match self {
            Node::Terraform { requires, .. } => requires,
            Node::NixOS     { requires, .. } => requires,
            Node::Ansible   { requires, .. } => requires,
            Node::Service   { requires, .. } => requires,
        }
    }
}


#[derive(Deserialize, Debug, PartialEq, Eq)]
pub struct Plan {
    pub nodes: Vec<Node>,
    pub order: Vec<String>,
}

pub trait Planner {
    fn plan(&self) -> Plan;
}

use std::process::Command;
use std::path::Path;

pub struct ApplyPlanner {
    cwd: Option<String>
}

impl ApplyPlanner {
    pub fn new() -> Self {
        Self {
            cwd: None
        }
    }

    pub fn current_dir(&mut self, dir: &Path) -> &mut Self {
        self.cwd = Some(String::from(dir.to_str().unwrap()));
        self
    }
}

impl Planner for ApplyPlanner {
    fn plan(&self) -> Plan {
        // pure flake output attribute evaluation
        let mut cmd = Command::new("nix");

        self.cwd.as_ref().inspect(|cwd| {
            cmd.current_dir(cwd);
        });

        let output = cmd.arg("eval")
            .arg(format!(".#nixus.{}.plan", eval_flake_system()))
            .arg("--json")
            .output()
            .expect("Failed to start plan evaluation");

        if !output.status.success() {
            println!("{}", &String::from_utf8(output.stdout).expect("stdout is not valid UTF-8"));
            println!("{}", &String::from_utf8(output.stderr).expect("stderr is not valid UTF-8"));
            panic!("Failed to evaluate plan");
        }

        let plan: Plan = serde_json::from_str(
            &String::from_utf8(output.stdout).expect("stdout is not valid UTF-8")
        ).unwrap();

        println!("{:#?}", plan);

        plan
    }
}

pub struct TargetedApplyPlanner {
    cwd   : Option<String>,
    target: String
}

impl TargetedApplyPlanner {
    pub fn new(target: &str) -> Self {
        Self {
            cwd   : None,
            target: String::from(target)
        }
    }

    pub fn current_dir(&mut self, dir: &Path) -> &mut Self {
        self.cwd = Some(String::from(dir.to_str().unwrap()));
        self
    }
}

impl Planner for TargetedApplyPlanner {
    fn plan(&self) -> Plan {

        let mut cmd = Command::new("nix");

        self.cwd.as_ref().inspect(|cwd| {
            cmd.current_dir(cwd);
        });

        let output = cmd.arg("eval")
            .arg(format!(".#nixus.{}.plan_of.{}", eval_flake_system(), self.target))
            .arg("--json")
            .output()
            .expect("Failed to start plan evaluation");

        if !output.status.success() {
            println!("{}", &String::from_utf8(output.stdout).expect("stdout is not valid UTF-8"));
            println!("{}", &String::from_utf8(output.stderr).expect("stderr is not valid UTF-8"));
            panic!("Failed to evaluate plan");
        }

        let plan: Plan = serde_json::from_str(
            &String::from_utf8(output.stdout).expect("stdout is not valid UTF-8")
        ).unwrap();

        println!("{:#?}", plan);

        plan
    }
}

pub fn eval_flake_system() -> String {
    let system_eval = Command::new("nix")
        .arg("eval")
        .arg("--impure")
        .arg("--expr")
        .arg("builtins.currentSystem")
        .output()
        .expect("Failed to start system string evaluation");

    let system_string = &String::from_utf8(system_eval.stdout).expect("API output is not valid UTF-8");

    let system = system_string.trim_end();

    return system.to_owned();
}

