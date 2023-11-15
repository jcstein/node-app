import React, { useState, useEffect, useRef } from "react";
import celestiaLogo from "./assets/celestia.svg";
import "./App.css";

interface AppProps {
  celestiaLogs: string[];
  celestiaVersion: () => void;
  celestiaInit: () => void;
  celestiaStart: () => void;
  celestiaStop: () => void;
  clearLogs: () => void;
  isRunning: boolean;
}

const App: React.FC<AppProps> = ({
  celestiaLogs,
  celestiaVersion,
  celestiaInit,
  celestiaStart,
  celestiaStop,
  clearLogs,
  isRunning,
}) => {
  const logsContainerRef = useRef<HTMLDivElement | null>(null);
  const [activeTab, setActiveTab] = useState("logs"); // Add this line

  useEffect(() => {
    setTimeout(() => {
      if (logsContainerRef.current) {
        logsContainerRef.current.scrollTop =
          logsContainerRef.current.scrollHeight;
      }
    }, 0);
  }, [celestiaLogs]);

  const handleTabClick = (tabName: string) => {
    // Modify this function
    setActiveTab(tabName);
  };

  const handleCelestiaInit = () => {
    setActiveTab('logs');
    celestiaInit();
  };

  const handleCelestiaVersion = () => {
    setActiveTab('logs');
    celestiaVersion();
  };  

  return (
    <div className="container" style={{ display: 'flex', flexDirection: 'column', height: '85vh' }}>
      <h1>{isRunning ? "Celestia light node is running on Mainnet Beta" : "Welcome to Pat!"}</h1>

      {!isRunning && (
        <>
          <div className="row">
            <a href="https://celestia.org" target="_blank" rel="noopener noreferrer">
              <img
                src={celestiaLogo}
                className="logo celestia"
                alt="Celestia logo"
              />
            </a>
          </div>

          <p>Click on the Celestia logo to learn more</p>

          <div style={{ display: 'flex', justifyContent: 'center', paddingBottom: '20px' }}>
          <button id="run-celestia" style={{ marginRight: '10px' }} onClick={handleCelestiaVersion}>Check version</button>
          <button id="init-celestia" style={{ marginRight: '10px' }} onClick={handleCelestiaInit}>Initialize light node</button>
          <button id="start-celestia" style={{ marginRight: '10px' }} onClick={celestiaStart}>Start light node</button>
            {celestiaLogs.length > 0 && <button id="clearLogs" onClick={clearLogs}>Clear Logs</button>}
          </div>
        </>
      )}

      {isRunning && (
        <div className="row" style={{ paddingBottom: '10px' }}>
          {isRunning && (activeTab === 'logs' ? 
            <button id="stats-button" style={{ marginRight: '10px' }} onClick={() => handleTabClick('stats')}>Show Stats</button>
            :
            <button id="logs-button" style={{ marginRight: '10px' }} onClick={() => handleTabClick('logs')}>Show Logs</button>
          )}
          <button id="stop-celestia" style={{ marginRight: '10px' }} onClick={celestiaStop}>Stop</button>
        </div>
      )}

      <div id="logs" ref={logsContainerRef} style={{ 
        flex: '1 1 auto',
        overflow: 'auto', 
        whiteSpace: 'pre-wrap', 
        textAlign: 'left', 
        display: activeTab === 'logs' ? 'block' : 'none',
        backgroundColor: '#000',
        color: '#0F0',
        fontFamily: 'Courier, monospace',
        paddingLeft: '10px',
        paddingRight: '10px',
      }}>
        <pre id="celestia-logs">{celestiaLogs.join('\n')}</pre>
      </div>
    
      <div id="stats" style={{ display: (activeTab === 'stats' && isRunning) ? 'block' : 'none' }}>
        <p>stats</p>
      </div>
    </div>
  );
}

export default App;