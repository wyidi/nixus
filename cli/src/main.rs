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


fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();

    use std::process::Command;
    use std::io::{self, Write};

    match &cli.command {
        Commands::Plan {} => {
            let output = Command::new("nix").arg("eval")
                .arg("--impure")
                .arg("--json")
                .arg("--expr")
                .arg(
                    r#"let
                      flake = builtins.getFlake (toString ./.);
                    in
                      flake.nixus.${builtins.currentSystem}.API.TopoSort { }
                "#)
                .output()?;

            println!("status: {}", output.status);
            io::stdout().write_all(&output.stdout)?;
            io::stderr().write_all(&output.stderr)?;

            Ok(())
        }
        Commands::Apply {} => {
            Ok(())
        }
        Commands::Destroy {} => {
            Ok(())
        }
    }
}
