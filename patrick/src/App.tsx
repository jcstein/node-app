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
  const [activeTab, setActiveTab] = useState("logs");

  useEffect(() => {
    setTimeout(() => {
      if (logsContainerRef.current) {
        logsContainerRef.current.scrollTop =
          logsContainerRef.current.scrollHeight;
      }
    }, 0);
  }, [celestiaLogs]);

  const handleTabClick = (tabName: string) => {
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
      <h1>{isRunning ? "Celestia light node running on Mainnet Beta ✨🤳" : <div>The fastest way to run a Celestia light node ✨</div>}</h1>
      <div style={{ display: 'flex', justifyContent: 'center', paddingBottom: '20px' }}>
      </div>
      {!isRunning && (
        <>
          <div style={{ display: 'flex', justifyContent: 'center', paddingBottom: '20px' }}>
          <button id="run-celestia" style={{ marginRight: '10px' }} onClick={handleCelestiaVersion}>Check version 🔢</button>
          <button id="init-celestia" style={{ marginRight: '10px' }} onClick={handleCelestiaInit}>Initialize light node 🧱</button>
          <button id="start-celestia" style={{ marginRight: '10px' }} onClick={celestiaStart}>Start light node 🟢</button>
            {celestiaLogs.length > 0 && <button id="clearLogs" onClick={clearLogs}>Clear Logs ❌</button>}
          </div>
        </>
      )}

      {isRunning && (
        <div className="row" style={{ paddingBottom: '20px' }}>
          {isRunning && (activeTab === 'logs' ? 
            <button id="stats-button" style={{ marginRight: '10px' }} onClick={() => handleTabClick('stats')}>Show stats 🧪</button>
            :
            <button id="logs-button" style={{ marginRight: '10px' }} onClick={() => handleTabClick('logs')}>Show logs 🖥️</button>
          )}
          <button id="stop-celestia" style={{ marginRight: '10px' }} onClick={celestiaStop}>Stop 🛑</button>
        </div>
      )}

      <div id="logs" ref={logsContainerRef} style={{ 
        flex: '1 1 auto',
        overflow: 'auto', 
        whiteSpace: 'pre-wrap', 
        textAlign: 'left', 
        display: activeTab === 'logs' && celestiaLogs.length > 0 ? 'block' : 'none',
        backgroundColor: '#000',
        color: '#0F0',
        fontFamily: 'Courier, monospace',
        paddingLeft: '10px',
        paddingRight: '10px',
      }}>
        <pre id="celestia-logs">{celestiaLogs.join('\n')}</pre>
      </div>
    
      <div id="stats" style={{ display: (activeTab === 'stats' && isRunning) ? 'block' : 'none' }}>
        <p>stats 🫡</p>
      </div>

      <div style={{ display: 'flex', justifyContent: 'center' }}>
        <img src={celestiaLogo} alt="Celestia logo" style={{ width: '69px', paddingTop: '10px' }} />
      </div>
    </div>
  );
}

export default App;