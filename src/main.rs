use clap::{Parser, Subcommand};

#[derive(Parser)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}


#[derive(Subcommand)]
enum Commands {
    Init    {},
    Plan    {},
    Apply   {},
    Destroy {},
}

fn main() {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Init {} => {

        }
        Commands::Plan {} => {

        }
        Commands::Apply {} => {

        }
        Commands::Destroy {} => {

        }
    }
}
