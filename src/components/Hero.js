import React from 'react';
import { motion } from 'framer-motion';
import './Hero.css';
import FloatingPhone from './FloatingPhone';

const Hero = ({ enable3D = true, lowPower = false }) => {
  const shouldAnimate = enable3D && !lowPower;

  return (
    <section className="hero" id="hero">
      <div className="hero-content">
        <motion.div
          className="hero-text"
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
        >
          <motion.div
            className="hero-badge glass"
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.6, delay: 0.4 }}
          >
            <span className="badge-icon">🚀</span>
            <span>10M+ Downloads Worldwide</span>
          </motion.div>

          <motion.h1
            className="hero-title"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.6 }}
          >
            Supercharge Your Phone's
            <br />
            <span className="gradient-text">Performance</span>
          </motion.h1>

          <motion.p
            className="hero-description"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.8 }}
          >
            Clean junk files, boost RAM, find duplicates, and optimize your device with AI-powered cleaning technology. Experience lightning-fast performance in seconds.
          </motion.p>

          <motion.div
            className="hero-buttons"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 1 }}
          >
            <motion.button
              className="btn-primary"
              whileHover={{ scale: 1.05, boxShadow: "0 20px 40px rgba(102, 126, 234, 0.4)" }}
              whileTap={{ scale: 0.95 }}
            >
              <span>Download Now</span>
              <span className="btn-icon">↓</span>
            </motion.button>

            <motion.button
              className="btn-secondary"
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              <span>Watch Demo</span>
              <span className="btn-icon">▶</span>
            </motion.button>
          </motion.div>

          <motion.div
            className="hero-stats"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.8, delay: 1.2 }}
          >
            <div className="stat-item">
              <div className="stat-number gradient-text-accent">4.8★</div>
              <div className="stat-label">App Rating</div>
            </div>
            <div className="stat-divider"></div>
            <div className="stat-item">
              <div className="stat-number gradient-text-accent">500K+</div>
              <div className="stat-label">5-Star Reviews</div>
            </div>
            <div className="stat-divider"></div>
            <div className="stat-item">
              <div className="stat-number gradient-text-accent">10M+</div>
              <div className="stat-label">Active Users</div>
            </div>
          </motion.div>
        </motion.div>

        <motion.div
          className="hero-visual"
          initial={{ opacity: 0, x: 100 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 1, delay: 0.4 }}
        >
          {enable3D ? (
            <FloatingPhone lowPower={lowPower} />
          ) : (
            <div className="phone-fallback glass-card" aria-hidden="true" />
          )}
          
          {/* Floating elements */}
          <motion.div
            className="floating-card glass-card card-1"
            animate={shouldAnimate ? { y: [0, -20, 0] } : {}}
            transition={shouldAnimate ? { duration: 4, repeat: Infinity, ease: "easeInOut" } : {}}
          >
            <div className="card-icon">🧹</div>
            <div className="card-text">
              <div className="card-title">Junk Cleaned</div>
              <div className="card-value">2.5 GB</div>
            </div>
          </motion.div>

          <motion.div
            className="floating-card glass-card card-2"
            animate={shouldAnimate ? { y: [0, 15, 0] } : {}}
            transition={shouldAnimate ? { duration: 5, repeat: Infinity, ease: "easeInOut", delay: 0.5 } : {}}
          >
            <div className="card-icon">⚡</div>
            <div className="card-text">
              <div className="card-title">Speed Boost</div>
              <div className="card-value">+85%</div>
            </div>
          </motion.div>

          <motion.div
            className="floating-card glass-card card-3"
            animate={shouldAnimate ? { y: [0, -15, 0] } : {}}
            transition={shouldAnimate ? { duration: 4.5, repeat: Infinity, ease: "easeInOut", delay: 1 } : {}}
          >
            <div className="card-icon">📊</div>
            <div className="card-text">
              <div className="card-title">Storage Saved</div>
              <div className="card-value">3.8 GB</div>
            </div>
          </motion.div>
        </motion.div>
      </div>

      {/* Gradient blobs */}
      <div className="gradient-blob blob-1 blob"></div>
      <div className="gradient-blob blob-2 blob"></div>
      <div className="gradient-blob blob-3 blob"></div>
    </section>
  );
};

export default Hero;
