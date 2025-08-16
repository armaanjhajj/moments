import React, { useState } from 'react'
import { Link } from 'react-router-dom'
import './App.css'

function BandPage() {
  const [isDarkMode, setIsDarkMode] = useState(true)

  const toggleTheme = () => {
    setIsDarkMode(!isDarkMode)
    document.body.classList.toggle('light-mode')
  }

  return (
    <div className={`App ${isDarkMode ? 'dark-mode' : 'light-mode'}`}>
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

      <div className="left-column">
        <Link to="/" className="back-button">
          ← BACK
        </Link>
        <h1 style={{ fontSize: 'clamp(40px, 7vw, 110px)', color: '#9e9e9e', marginBottom: '2rem' }}>
          BAND PAGE
        </h1>
        <p style={{ fontSize: 'clamp(16px, 2.5vw, 24px)', color: '#9e9e9e' }}>
          This is the band page.
        </p>
      </div>
    </div>
  )
}

export default BandPage
