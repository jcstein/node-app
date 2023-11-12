import React, { useState, useEffect, useRef } from 'react';
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

const App: React.FC<AppProps> = ({ celestiaLogs, celestiaVersion, celestiaInit, celestiaStart, celestiaStop, clearLogs, isRunning }) => {

  const logsContainerRef = useRef<HTMLDivElement | null>(null);
  const [activeTab, setActiveTab] = useState('logs'); // Add this line

  useEffect(() => {
    setTimeout(() => {
      if (logsContainerRef.current) {
        logsContainerRef.current.scrollTop = logsContainerRef.current.scrollHeight;
      }
    }, 0);
  }, [celestiaLogs]);

  const handleTabClick = (tabName: string) => { // Modify this function
    setActiveTab(tabName);
  };

  return (
    <div className="container">
      <h1>Welcome to Patrick!</h1>

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
        <button id="run-celestia" style={{ marginRight: '10px' }} onClick={celestiaVersion}>Check version</button>
        <button id="init-celestia" style={{ marginRight: '10px' }} onClick={celestiaInit}>Initialize light node</button>
        <button id="start-celestia" style={{ marginRight: '10px' }} onClick={celestiaStart}>Start light node</button>
        <button id="stop-celestia" style={{ marginRight: '10px' }} onClick={celestiaStop}>Stop</button>
        <button id="clearLogs" onClick={clearLogs}>Clear Logs</button>
      </div>

      <div style={{ display: 'flex', justifyContent: 'center', paddingBottom: '20px' }}>
        {isRunning && (activeTab === 'logs' ? 
          <button id="stats-button" style={{ marginRight: '10px' }} onClick={() => handleTabClick('stats')}>Show Stats</button>
          :
          <button id="logs-button" style={{ marginRight: '10px' }} onClick={() => handleTabClick('logs')}>Show Logs</button>
        )}
      </div>
      
      <div id="logs" ref={logsContainerRef} style={{ width: '100%', height: '50vh', overflow: 'auto', whiteSpace: 'pre-wrap', overflowY: 'auto', resize: 'vertical', textAlign: 'left', display: activeTab === 'logs' ? 'block' : 'none' }}>
        <pre id="celestia-logs">{celestiaLogs.join('\n')}</pre>
      </div>
    
      <div id="stats" style={{ display: activeTab === 'stats' ? 'block' : 'none' }}>
        <p>stats</p>
      </div>
    </div>
  );
}

export default App;