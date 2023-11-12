use std::process::{Command, Stdio};
use std::sync::{Arc, Mutex};
use std::thread;
use std::io::{BufRead, BufReader};
use lazy_static::lazy_static;
use sysinfo::{System, SystemExt, ProcessExt};

fn kill_process_by_name(name: &str) -> Result<(), String> {
    let mut system = System::new_all();
    system.refresh_all();

    for (pid, process) in system.processes() {
        if process.name() == name {
            std::process::Command::new("kill")
                .arg("-9")
                .arg(pid.to_string())
                .output()
                .expect("failed to execute process");
            return Ok(());
        }
    }

    Err(format!("No process with name {} found", name))
}

#[tauri::command]
fn celestia_version() -> String {
  let output = Command::new("./celestia")
    .arg("version")
    .output()
    .expect("failed to execute process");

  String::from_utf8_lossy(&output.stdout).to_string()
}

#[tauri::command]
fn celestia_init() -> Result<String, tauri::InvokeError> {
  let output = Command::new("./celestia")
    .arg("light")
    .arg("init")
    .output()
    .map_err(|e| tauri::InvokeError::from(e.to_string()))?;

  Ok(String::from_utf8_lossy(&output.stderr).to_string())
}

lazy_static! {
  static ref OUTPUT: Arc<Mutex<Vec<String>>> = Arc::new(Mutex::new(Vec::new()));
}

#[tauri::command]
fn celestia_start() -> Result<String, tauri::InvokeError> {
  let home_dir = dirs::home_dir().ok_or("Could not get home directory")?;
  let output_dir = home_dir.join(".celestia-light");
  let output_file = output_dir.join("logs.txt");

  // Create the directory if it doesn't exist
  match std::fs::create_dir_all(&output_dir) {
    Ok(_) => (),
    Err(e) => return Err(tauri::InvokeError::from(e.to_string())),
  };

  // Create the file if it doesn't exist
  match std::fs::OpenOptions::new()
    .write(true)
    .create(true)
    .open(&output_file) {
    Ok(_) => (),
    Err(e) => return Err(tauri::InvokeError::from(e.to_string())),
  };

  let mut child = Command::new("sh")
    .arg("-c")
    .arg(format!("./celestia light start --core.ip rpc.celestia.pops.one 2>&1 | tee {}", output_file.to_str().unwrap()))
    .stdout(Stdio::piped())
    .spawn()
    .map_err(|e| tauri::InvokeError::from(e.to_string()))?;

  let reader = BufReader::new(child.stdout.take().unwrap());

  let output_arc = Arc::clone(&OUTPUT);
  thread::spawn(move || {
    for line in reader.lines() {
      let line = line.unwrap();
      let mut output = output_arc.lock().unwrap();
      output.push(line);
    }
  });

  Ok("Process started".to_string())
}

#[tauri::command]
fn get_output() -> Result<Vec<String>, tauri::InvokeError> {
  let output = OUTPUT.lock().unwrap().clone();
  Ok(output)
}

#[tauri::command]
fn celestia_stop() -> Result<String, tauri::InvokeError> {
    match kill_process_by_name("celestia") {
        Ok(_) => Ok("Celestia light node successfully stopped".to_string()),
        Err(e) => Err(tauri::InvokeError::from(e)),
    }
}

fn main() {
  tauri::Builder::default()
      .invoke_handler(tauri::generate_handler![celestia_version, celestia_init, celestia_start, get_output, celestia_stop])
      .run(tauri::generate_context!())
      .expect("error while running tauri application");
}