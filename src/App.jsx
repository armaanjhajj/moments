import { useState } from 'react'
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom'
import './App.css'
import AppPage from './AppPage'
import BandPage from './BandPage'
import LearnMorePage from './LearnMorePage'
import TermsPage from './TermsPage'
import PrivacyPage from './PrivacyPage'

function HomePage() {
  const [isDarkMode, setIsDarkMode] = useState(true)

  const toggleTheme = () => {
    setIsDarkMode(!isDarkMode)
    document.body.classList.toggle('light-mode')
  }

  return (
    <div className={`App ${isDarkMode ? 'dark-mode' : 'light-mode'}`}>
      {/* Top-right corner */}
      <div className="top-right">
        <button className="join-button">JOIN NOW</button>
        <button className="theme-toggle" onClick={toggleTheme}>
          {isDarkMode ? '☀' : '☾'}
        </button>
        <img 
          src="https://i.imgur.com/RfKfYXS.jpeg" 
          alt="Logo" 
          className="logo"
        />
      </div>

      {/* Left column */}
      <div className="left-column">
        <ol className="main-list">
          <li>
            <Link to="/app">
              1 APP
            </Link>
          </li>
          <li>
            <Link to="/band">
              2 BAND
            </Link>
          </li>
        </ol>
        
        <div className="commented-links">
          <Link to="/learn-more">
            // LEARN MORE
          </Link>
          <Link to="/terms">
            // TERMS OF SERVICE
          </Link>
          <Link to="/privacy">
            // PRIVACY POLICY
          </Link>
        </div>
      </div>
    </div>
  )
}

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/app" element={<AppPage />} />
        <Route path="/band" element={<BandPage />} />
        <Route path="/learn-more" element={<LearnMorePage />} />
        <Route path="/terms" element={<TermsPage />} />
        <Route path="/privacy" element={<PrivacyPage />} />
      </Routes>
    </Router>
  )
}

export default App
