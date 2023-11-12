import React, { useState, useCallback, useEffect, useRef } from "react";
import ReactDOM from "react-dom";
import { invoke } from "@tauri-apps/api/tauri";
import App from "./App";
import "./styles.css";

function Main() {
  const [celestiaLogs, setCelestiaLogs] = useState<string[]>([]);
  const celestiaLogsRef = useRef(celestiaLogs);
  celestiaLogsRef.current = celestiaLogs;

  const [isRunning, setIsRunning] = useState(false);
  const isRunningRef = useRef(isRunning);
  isRunningRef.current = isRunning;

  useEffect(() => {
    const clearLogsButton = document.querySelector("#clearLogs");
    const clearLogs = () => setCelestiaLogs([]);
    clearLogsButton?.addEventListener("click", clearLogs);

    // Clean up the event listener when the component is unmounted
    return () => {
      clearLogsButton?.removeEventListener("click", clearLogs);
    };
  }, []);
  
  const celestiaVersion = useCallback(async () => {
    const output = await invoke("celestia_version");
    setCelestiaLogs(prevLogs => [...prevLogs, `Celestia light node version: ${String(output)}\n`]);
  }, []);

  const celestiaInit = useCallback(async () => {
    const output = await invoke("celestia_init");
    setCelestiaLogs(prevLogs => [...prevLogs, `Initialize Celestia light node: ${String(output)}\n`]);
  }, []);

  const celestiaStart = useCallback(async () => {
    setIsRunning(true);
    await invoke("celestia_start");
    setCelestiaLogs(prevLogs => [...prevLogs, `Starting Celestia light node...`]);
  
    // Start a loop to continuously get the latest output
    while (isRunningRef.current) {
      const output = (await invoke("get_output")) as string[];
      if (output.length > celestiaLogsRef.current.length) {
        const newLogs = output.slice(celestiaLogsRef.current.length);
        setCelestiaLogs(prevLogs => [...prevLogs, ...newLogs]);
      }
      await new Promise(resolve => setTimeout(resolve, 1000));  // Wait for 1 second
    }
  }, []);
  
  const celestiaStop = useCallback(async () => {
    setIsRunning(false);
    const message = await invoke("celestia_stop");
    setCelestiaLogs(prevLogs => [...prevLogs, `Stopping Celestia light node...\n${message}\n`]);
  }, []);

  return <App celestiaLogs={celestiaLogs} celestiaVersion={celestiaVersion} celestiaInit={celestiaInit} celestiaStart={celestiaStart} celestiaStop={celestiaStop} clearLogs={() => setCelestiaLogs([])} isRunning={isRunning} />;}

ReactDOM.render(
  <React.StrictMode>
    <Main />
  </React.StrictMode>,
  document.getElementById("root")
);