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

    use std::collections::HashMap;

    match &cli.command {
        Commands::Plan {} => {
            let plan = nixus::topological_sort(None);

            let mut nodes = HashMap::new();

            for (idx, node) in plan.nodes.iter().enumerate() {
                nodes.insert(node.id(), idx);
            }
        }
        Commands::Apply {} => {

        }
        Commands::Destroy {} => {

        }
    }
}
