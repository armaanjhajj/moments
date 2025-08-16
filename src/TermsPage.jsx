import React, { useState } from 'react'
import { Link } from 'react-router-dom'
import './App.css'

function TermsPage() {
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
          TERMS OF SERVICE
        </h1>
        <div style={{ fontSize: 'clamp(14px, 2vw, 18px)', color: '#9e9e9e', lineHeight: '1.6', maxWidth: '800px' }}>
          <p style={{ marginBottom: '1rem' }}><strong>Last Updated: August 8, 2025</strong></p>
          
          <p style={{ marginBottom: '1rem' }}>
            These Terms of Service ("Terms") are a binding agreement between you ("you," "User") and Impulse Labs, Inc. ("Impulse," "we"). By accessing or using our Website, App, or Wearable (collectively, the "Services"), you agree to these Terms and our Privacy Policy.
          </p>
          
          <p style={{ marginBottom: '2rem', fontWeight: 'bold' }}>
            Read this carefully: These Terms include a binding arbitration provision and class‑action waiver (see Section 16).
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>1. WHAT IMPULSE DOES</h2>
          <p style={{ marginBottom: '1rem' }}>
            Impulse helps you discover compatible people nearby, act in the moment, and confirm connections only if you meet in person (e.g., via a band tap or in‑app confirmation). We may offer an optional Wearable (Impulse Band™) that lights up to indicate status/mood and enables quick contact exchange.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>2. ELIGIBILITY</h2>
          <p style={{ marginBottom: '1rem' }}>
            You must be 18+, able to form a contract, and not prohibited from using the Services under applicable law.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>3. ACCOUNT & SECURITY</h2>
          <p style={{ marginBottom: '1rem' }}>
            Register with accurate information. Keep your device and login codes secure. You are responsible for activity on your account. Notify us of unauthorized use.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>4. LICENSE</h2>
          <p style={{ marginBottom: '1rem' }}>
            We grant you a limited, non‑exclusive, non‑transferable license to use the Services for personal, non‑commercial purposes, subject to these Terms.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>5. ACCEPTABLE USE</h2>
          <p style={{ marginBottom: '1rem' }}>Do not:</p>
          <ul style={{ marginBottom: '1rem', paddingLeft: '2rem' }}>
            <li>harass, stalk, or harm others; post illegal, hateful, or explicit content; or violate campus or venue rules;</li>
            <li>scrape, reverse engineer, or interfere with the Services;</li>
            <li>use the Services to send spam, scams, or unauthorized commercial messages;</li>
            <li>circumvent safety features or attempt unauthorized access.</li>
          </ul>
          <p style={{ marginBottom: '1rem' }}>
            We may remove content or suspend accounts that violate these Terms.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>6. WEARABLE & SAFETY</h2>
          <p style={{ marginBottom: '1rem' }}>
            Use the Wearable responsibly. The light signals are informational only and do not guarantee consent or safety. Always respect others' boundaries and local laws. Do not use the Wearable while operating vehicles or in restricted locations.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>7. MESSAGING & CONSENT</h2>
          <p style={{ marginBottom: '1rem' }}>
            By providing your phone number, you agree to receive transactional texts (e.g., login codes, confirmations, critical updates). Marketing texts require your opt‑in; you may opt out at any time. Carrier rates may apply. We may use third‑party providers (e.g., Twilio) to deliver messages.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>8. USER CONTENT & FEEDBACK</h2>
          <p style={{ marginBottom: '1rem' }}>
            You retain rights to content you submit (profiles, photos, tags). You grant Impulse a worldwide, non‑exclusive, royalty‑free license to host, display, and use your content to operate and improve the Services. You grant us the right to use feedback without restriction.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>9. VIRTUAL & PHYSICAL EVENTS</h2>
          <p style={{ marginBottom: '1rem' }}>
            If we run events, additional rules may apply. You participate at your own risk and agree to follow all posted instructions and venue policies.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>10. THIRD‑PARTY LINKS & SERVICES</h2>
          <p style={{ marginBottom: '1rem' }}>
            We are not responsible for third‑party sites/services. Your use of them is at your own risk and subject to their terms.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>11. PAYMENTS (IF APPLICABLE)</h2>
          <p style={{ marginBottom: '1rem' }}>
            If products or subscriptions are offered, prices will be shown in‑app or on the Website. Taxes and shipping (if any) are additional. All sales are subject to our posted refund/return policy.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>12. DISCLAIMER</h2>
          <p style={{ marginBottom: '1rem' }}>
            The Services are provided "AS IS" without warranties of any kind. We do not guarantee matches, connection outcomes, or uninterrupted availability.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>13. LIMITATION OF LIABILITY</h2>
          <p style={{ marginBottom: '1rem' }}>
            To the maximum extent permitted by law, Impulse will not be liable for indirect, incidental, special, consequential, exemplary, or punitive damages. Our total liability for any claim will not exceed the greater of $100 or amounts you paid to Impulse in the 3 months preceding the event giving rise to the claim.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>14. INDEMNITY</h2>
          <p style={{ marginBottom: '1rem' }}>
            You agree to defend, indemnify, and hold harmless Impulse and our officers, directors, employees, and agents from claims arising out of (a) your use of the Services; (b) your content; or (c) your violation of these Terms or law.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>15. TERMINATION</h2>
          <p style={{ marginBottom: '1rem' }}>
            You may stop using the Services at any time. We may suspend or terminate access for any reason, including violations of these Terms. Sections intended to survive termination will survive.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>16. DISPUTE RESOLUTION; ARBITRATION; CLASS WAIVER</h2>
          <p style={{ marginBottom: '1rem' }}>
            <strong>Binding Arbitration.</strong> Except for small‑claims matters or equitable relief for IP/security, disputes will be resolved by final and binding arbitration on an individual basis. No class actions or representative proceedings. The Federal Arbitration Act governs this section. Venue for any court proceedings (e.g., to confirm an award) will be New York County, New York.
          </p>
          <p style={{ marginBottom: '1rem' }}>
            <strong>Opt‑Out:</strong> You may opt out of arbitration within 30 days of first acceptance by emailing info@theimpulse.xyz with subject "Arbitration Opt‑Out," your name, and the phone number tied to your account.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>17. GOVERNING LAW</h2>
          <p style={{ marginBottom: '1rem' }}>
            Delaware law governs these Terms (without regard to conflicts of laws).
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>18. CHANGES TO THESE TERMS</h2>
          <p style={{ marginBottom: '1rem' }}>
            We may update these Terms. Material changes will be posted in‑app/on the Website (and by email/SMS where appropriate). Continued use means you accept the updated Terms.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>19. CONTACT</h2>
          <p style={{ marginBottom: '1rem' }}>
            <strong>Impulse Labs, Inc.</strong><br />
            Email: info@theimpulse.xyz
          </p>
        </div>
      </div>
    </div>
  )
}

export default TermsPage
