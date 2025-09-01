import cli
import gleam/io

pub fn main() -> Nil {
  case cli.prompt_command() {
    Error(s) -> io.println(s)
    Ok(cmd) -> {
      echo cmd
      Nil
    }
  }
}
