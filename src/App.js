import React, { useEffect, useState } from 'react';
import { MotionConfig } from 'framer-motion';
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
import { getPerformanceProfile } from './utils/performance';

function App() {
  const [currentPage, setCurrentPage] = useState('home');
  const [performanceProfile, setPerformanceProfile] = useState(() => getPerformanceProfile());

  const reduceMotion =
    performanceProfile.prefersReducedMotion || performanceProfile.lowEndDevice;
  const showParticles = !reduceMotion;

  // Simple routing
  useEffect(() => {
    const handleHashChange = () => {
      const hash = window.location.hash.slice(1);
      setCurrentPage(hash || 'home');
    };

    window.addEventListener('hashchange', handleHashChange);
    handleHashChange();

    return () => window.removeEventListener('hashchange', handleHashChange);
  }, []);

  useEffect(() => {
    const updateProfile = () => setPerformanceProfile(getPerformanceProfile());
    const motionQuery = window.matchMedia?.('(prefers-reduced-motion: reduce)');

    motionQuery?.addEventListener('change', updateProfile);
    window.addEventListener('resize', updateProfile);

    return () => {
      motionQuery?.removeEventListener('change', updateProfile);
      window.removeEventListener('resize', updateProfile);
    };
  }, []);

  useEffect(() => {
    document.body.classList.toggle('reduce-motion', reduceMotion);
  }, [reduceMotion]);

  return (
    <MotionConfig reducedMotion={reduceMotion ? 'always' : 'user'}>
      <div className="App">
        {showParticles && (
          <ParticlesBackground lowPower={performanceProfile.lowEndDevice} />
        )}
        <Navbar currentPage={currentPage} setCurrentPage={setCurrentPage} />
        
        {currentPage === 'home' ? (
          <>
            <Hero enable3D={!reduceMotion} lowPower={performanceProfile.lowEndDevice} />
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
            <Hero enable3D={!reduceMotion} lowPower={performanceProfile.lowEndDevice} />
            <Features />
            <HowItWorks />
            <Stats />
            <Testimonials />
            <Download />
          </>
        )}
        
        <Footer setCurrentPage={setCurrentPage} />
      </div>
    </MotionConfig>
  );
}

export default App;
