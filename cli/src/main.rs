use clap::{Parser, Subcommand};

#[derive(Parser)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}


#[derive(Subcommand)]
enum Commands {
    Plan    {},
    Apply   {},
    Destroy {},
}


fn main() {
    let cli = Cli::parse();

    use std::process::Command;

    match &cli.command {
        Commands::Plan {} => {
            let output = Command::new("nix").arg("eval")
                .arg("--impure")
                .arg("--json")
                .arg("--expr")
                .arg(r#"
                let
                    flake = builtins.getFlake (toString ./.);
                in
                    flake.nixus.${builtins.currentSystem}.API.TopoSort { }
                "#)
                .output()
                .expect("Failed to spawn nix process");

            println!("status: {}", output.status);

            use std::io::{self, Write};
            io::stdout().write_all(&output.stdout).expect("Failed to stdout");
            io::stderr().write_all(&output.stderr).expect("Failed to stderr");
        }
        Commands::Apply {} => {

        }
        Commands::Destroy {} => {

        }
    }
}
