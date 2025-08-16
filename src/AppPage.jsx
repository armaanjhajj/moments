import React, { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import './App.css'

function AppPage() {
  const [isDarkMode, setIsDarkMode] = useState(true)
  const [currentCaption, setCurrentCaption] = useState(0)
  const [email, setEmail] = useState('')
  const [isSubmitted, setIsSubmitted] = useState(false)

  const toggleTheme = () => {
    setIsDarkMode(!isDarkMode)
    document.body.classList.toggle('light-mode')
  }

  const captions = [
    "build a network of in-person connections",
    "tap phones to exchange contact instantly", 
    "discover compatible people around you",
    "be alerted when someone interesting is nearby",
    "you have moments to make the connection",
    "embrace the impulse or lose the chance",
    "real connections happen in real time",
    "your network grows through genuine encounters"
  ]

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentCaption((prev) => (prev + 1) % captions.length)
    }, 2500)
    return () => clearInterval(interval)
  }, [])

  const handleEmailSubmit = (e) => {
    e.preventDefault()
    if (email.trim()) {
      setIsSubmitted(true)
    }
  }

  return (
    <div className={`App app-page ${isDarkMode ? 'dark-mode' : 'light-mode'}`}>
      {/* Top navigation bar */}
      <div className="app-nav">
        <div className="app-nav-left">impulse</div>
        <div className="app-nav-center">𝔞𝔭𝔭</div>
        <Link to="/" className="app-nav-right">✕</Link>
      </div>

      {/* Scrolling top text */}
      <div className="scrolling-text-top">
        <div className="scrolling-content">
          IMPULSE • MOBILE APPLICATION • LAUNCHES FALL 2025 • IMPULSE • MOBILE APPLICATION • LAUNCHES FALL 2025 • IMPULSE • MOBILE APPLICATION • LAUNCHES FALL 2025 • IMPULSE • MOBILE APPLICATION • LAUNCHES FALL 2025 • IMPULSE • MOBILE APPLICATION • LAUNCHES FALL 2025 • 
        </div>
      </div>

      {/* Video background */}
      <div className="video-container">
        <video 
          autoPlay 
          loop 
          muted 
          playsInline
          className="background-video"
        >
          <source src="https://i.imgur.com/QcQlVeF.mp4" type="video/mp4" />
        </video>
        
        {/* Caption overlay */}
        <div className="caption-overlay">
          <div className="tv-caption">{captions[currentCaption]}</div>
        </div>
      </div>

      {/* Scrolling bottom text */}
      <div className="scrolling-text-bottom">
        <div className="scrolling-content">
          APP • REAL CONNECTIONS • SPONTANEOUS ENCOUNTERS • APP • REAL CONNECTIONS • SPONTANEOUS ENCOUNTERS • APP • REAL CONNECTIONS • SPONTANEOUS ENCOUNTERS • APP • REAL CONNECTIONS • SPONTANEOUS ENCOUNTERS • APP • REAL CONNECTIONS • SPONTANEOUS ENCOUNTERS • 
        </div>
      </div>

      {/* Info box overlay */}
      <div className="app-info-overlay">
        <div className="app-info-box">
          <div className="app-info-header">
            <span>MOBILE APPLICATION</span>
            <span>FALL 2025</span>
          </div>
          
          <div className="app-title">𝔞𝔭𝔭</div>
          
          <div className="app-details">
            <p>RSVP NOW</p>
            <p>IOS ONLY</p>
          </div>

        {!isSubmitted ? (
          <form onSubmit={handleEmailSubmit} className="email-form">
            <div className="email-input-container">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="ENTER E-MAIL TO RSVP"
                className="email-input"
                required
              />
              <button type="submit" className="email-submit">→</button>
            </div>
          </form>
        ) : (
          <div className="email-success">
            <p>YOUR EMAIL HAS BEEN ADDED TO THE WAITLIST</p>
          </div>
        )}

          <div className="app-description">
            <p>Experience the art of spontaneous connection. The Impulse app transforms chance encounters into meaningful relationships through proximity-based discovery and time-sensitive interactions.</p>
          </div>
        </div>
      </div>
      
      {/* App preview image overlay - top left */}
      <div className="app-preview-overlay">
        <img src="https://i.imgur.com/Dz10kt0.png" alt="App Preview" className="preview-image-small" />
      </div>
      
    </div>
  )
}

export default AppPage
