import React, { useState } from 'react'
import { Link } from 'react-router-dom'
import './App.css'

function PrivacyPage() {
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
          PRIVACY POLICY
        </h1>
        <div style={{ fontSize: 'clamp(14px, 2vw, 18px)', color: '#9e9e9e', lineHeight: '1.6', maxWidth: '800px' }}>
          <p style={{ marginBottom: '1rem' }}><strong>Last Updated: August 8, 2025</strong></p>
          
          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>0. PERSONA BACKGROUND CHECKS</h2>
          <p style={{ marginBottom: '1rem' }}>
            Impulse may use third‑party services such as Persona to perform identity verification or background checks for safety and trust purposes. These checks may involve collecting information you provide (e.g., name, date of birth, government‑issued ID, and selfie) and comparing it against public records or databases. The results are used solely to assess eligibility for certain features or to enhance community safety. We do not store your government‑issued ID images or raw background data; they are processed directly by the verification provider. Your use of features requiring verification constitutes consent to this processing.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>1. INTRODUCTION</h2>
          <p style={{ marginBottom: '1rem' }}>
            Impulse Labs, Inc. ("Impulse," "we," "us," or "our") respects your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard information when you use the Impulse platform (the "Platform"), including our website at https://theimpulse.xyz (the "Website"), our mobile application (the "App"), and our wearable device(s) such as the Impulse Band™ (the "Wearable"). Impulse is designed to help you meet people in real life and build a network of contacts you've actually met.
          </p>
          <p style={{ marginBottom: '1rem' }}>
            By accessing or using the Website, App, or Wearable, you agree to this Privacy Policy. If you do not agree, please do not use the Platform.
          </p>
          <p style={{ marginBottom: '1rem' }}>
            For any privacy questions, contact us at info@theimpulse.xyz.
          </p>
          <p style={{ marginBottom: '2rem' }}>
            We do not sell your personal information. We share personal information only with service providers and subprocessors to operate the Platform (e.g., cloud hosting, messaging/SMS providers).
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>2. INFORMATION WE COLLECT</h2>
          <p style={{ marginBottom: '1rem' }}>
            We collect information in three ways: (a) you provide it to us; (b) we collect it automatically when you use the Platform; and (c) from service providers and integration partners you enable.
          </p>

          <h3 style={{ fontSize: 'clamp(18px, 3vw, 24px)', color: '#fff', marginBottom: '1rem' }}>a. Information You Provide</h3>
          <ul style={{ marginBottom: '1rem', paddingLeft: '2rem' }}>
            <li><strong>Account Info:</strong> name, phone number (used for login and SMS updates), photo, profile details (interests, short bio), and campus/region.</li>
            <li><strong>Connections:</strong> when you confirm an in-person connection, notes or tags you add to a contact, and your consent choices.</li>
            <li><strong>Support & Comms:</strong> messages you send us (email, in-app forms), survey responses, or interview consents.</li>
          </ul>

          <h3 style={{ fontSize: 'clamp(18px, 3vw, 24px)', color: '#fff', marginBottom: '1rem' }}>b. Information Collected Automatically</h3>
          <ul style={{ marginBottom: '1rem', paddingLeft: '2rem' }}>
            <li><strong>Approximate Location</strong> (while the App is in use) to surface nearby matches; precise GPS may be requested for certain features, with your permission.</li>
            <li><strong>Bluetooth & NFC signals</strong> to detect band taps and confirm in‑person contact with the Wearable.</li>
            <li><strong>Device & Usage Data:</strong> device identifiers, IP address, app version, browser type, referring/exit pages, clicks, and session analytics.</li>
            <li><strong>Cookies & Similar Tech</strong> on the Website for preferences and analytics. See Section 5 (Cookie Policy).</li>
          </ul>

          <h3 style={{ fontSize: 'clamp(18px, 3vw, 24px)', color: '#fff', marginBottom: '1rem' }}>c. Information From Service Providers</h3>
          <ul style={{ marginBottom: '1rem', paddingLeft: '2rem' }}>
            <li><strong>Messaging (SMS):</strong> We use providers (e.g., Twilio) to deliver one‑time passcodes and transactional texts. Your phone number and message metadata are processed to deliver these communications.</li>
            <li><strong>Payments/Commerce</strong> (if enabled): processed by third‑party processors; we do not store full payment card numbers.</li>
          </ul>
          <p style={{ marginBottom: '1rem' }}>
            <strong>Sensitive data:</strong> We do not request health, financial account numbers, government IDs, or address books. Do not upload sensitive information to your profile.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>3. HOW WE USE INFORMATION</h2>
          <p style={{ marginBottom: '1rem' }}>We use information to:</p>
          <ul style={{ marginBottom: '1rem', paddingLeft: '2rem' }}>
            <li>Provide, secure, and improve the Platform and Wearable experience.</li>
            <li>Surface compatible nearby users and time‑bound prompts to meet in person.</li>
            <li>Confirm connections only when you act in real life (e.g., band tap / NFC).</li>
            <li>Send transactional messages (login codes, confirmations, critical updates). Marketing texts are sent only with consent; standard carrier rates may apply.</li>
            <li>Prevent fraud/abuse, debug, perform analytics, and comply with legal obligations.</li>
          </ul>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>4. LEGAL BASES (EEA/UK USERS)</h2>
          <p style={{ marginBottom: '1rem' }}>
            Where applicable, we rely on: performance of contract, legitimate interests (product security and core features), consent (location, notifications, marketing), and legal obligations.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>5. COOKIE POLICY (WEBSITE)</h2>
          <p style={{ marginBottom: '1rem' }}>
            We use cookies and similar technologies to remember preferences, measure performance, and improve the site. You can control cookies via your browser or our cookie banner/settings. If you enable "Do Not Track," we will honor it where technically feasible.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>6. HOW WE SHARE INFORMATION</h2>
          <p style={{ marginBottom: '1rem' }}>We share information only with:</p>
          <ul style={{ marginBottom: '1rem', paddingLeft: '2rem' }}>
            <li><strong>Service Providers/Subprocessors</strong> under contract (hosting, analytics, SMS, crash reporting, content delivery, customer support).</li>
            <li><strong>Safety & Legal:</strong> if required by law, to protect rights, safety, or investigate abuse.</li>
            <li><strong>Business Transfers:</strong> in a merger/acquisition, your information may be transferred with notice and choices as required by law.</li>
          </ul>
          <p style={{ marginBottom: '1rem' }}>
            We do not sell or rent personal information.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>7. DATA RETENTION</h2>
          <p style={{ marginBottom: '1rem' }}>
            We retain personal data while your account is active and as needed to provide the Platform. After account deletion, we delete or anonymize data within 90 days, unless a longer period is required for legal, security, or fraud‑prevention reasons. SMS delivery logs may be retained by providers per their policies.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>8. SECURITY</h2>
          <p style={{ marginBottom: '1rem' }}>
            We use industry‑standard safeguards, including encryption in transit, restricted access, and routine security reviews. No method of transmission or storage is 100% secure; you use the Platform at your own risk. Protect your device and account codes.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>9. YOUR RIGHTS & CHOICES</h2>
          <ul style={{ marginBottom: '1rem', paddingLeft: '2rem' }}>
            <li><strong>Permissions:</strong> You can disable location, Bluetooth, NFC, and notifications in your device settings (some features may stop working).</li>
            <li><strong>Access/Deletion:</strong> Request access, correction, or deletion at info@theimpulse.xyz. We will verify your request and respond as required by law.</li>
            <li><strong>Marketing Opt‑Out:</strong> You can opt out of marketing emails/texts via the message or by contacting us. Transactional messages may still be sent.</li>
          </ul>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>10. CHILDREN</h2>
          <p style={{ marginBottom: '1rem' }}>
            The Platform is for users 18+. We do not knowingly collect data from users under 18. If you believe a minor has provided data, contact info@theimpulse.xyz for removal.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>11. INTERNATIONAL TRANSFERS</h2>
          <p style={{ marginBottom: '1rem' }}>
            We are based in the United States. Your information may be processed in the U.S. and other countries with different data‑protection laws. Where required, we implement appropriate safeguards (e.g., SCCs).
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>12. CHANGES TO THIS POLICY</h2>
          <p style={{ marginBottom: '1rem' }}>
            We may update this Policy from time to time. Material changes will be announced on the Website/App or via email/SMS. Continued use after changes means you accept the updated Policy.
          </p>

          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', color: '#fff', marginBottom: '1rem' }}>13. CONTACT</h2>
          <p style={{ marginBottom: '1rem' }}>
            <strong>Impulse Labs, Inc.</strong><br />
            Email: info@theimpulse.xyz
          </p>
        </div>
      </div>
    </div>
  )
}

export default PrivacyPage
