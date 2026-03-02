import React, { useState } from 'react';
import './App.css';
import Navbar from './components/Navbar';
import Hero from './components/Hero';
import Features from './components/Features';
import HowItWorks from './components/HowItWorks';
import Stats from './components/Stats';
import Testimonials from './components/Testimonials';
import Download from './components/Download';
import Footer from './components/Footer';
import ParticlesBackground from './components/ParticlesBackground';
import PrivacyPolicy from './components/PrivacyPolicy';

function App() {
  const [currentPage, setCurrentPage] = useState('home');

  // Simple routing
  React.useEffect(() => {
    const handleHashChange = () => {
      const hash = window.location.hash.slice(1);
      setCurrentPage(hash || 'home');
    };

    window.addEventListener('hashchange', handleHashChange);
    handleHashChange();

    return () => window.removeEventListener('hashchange', handleHashChange);
  }, []);

  return (
    <div className="App">
      <ParticlesBackground />
      <Navbar currentPage={currentPage} setCurrentPage={setCurrentPage} />
      
      {currentPage === 'home' ? (
        <>
          <Hero />
          <Features />
          <HowItWorks />
          <Stats />
          <Testimonials />
          <Download />
        </>
      ) : currentPage === 'privacy' ? (
        <PrivacyPolicy />
      ) : (
        <>
          <Hero />
          <Features />
          <HowItWorks />
          <Stats />
          <Testimonials />
          <Download />
        </>
      )}
      
      <Footer setCurrentPage={setCurrentPage} />
    </div>
  );
}

export default App;
