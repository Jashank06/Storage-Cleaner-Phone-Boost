import React from 'react';
import { motion } from 'framer-motion';
import { useInView } from 'react-intersection-observer';
import './Download.css';

const Download = () => {
  const [ref, inView] = useInView({
    threshold: 0.3,
    triggerOnce: true,
  });

  return (
    <section className="download" id="download">
      <div className="container">
        <motion.div
          ref={ref}
          className="download-card glass-card"
          initial={{ opacity: 0, scale: 0.9 }}
          animate={inView ? { opacity: 1, scale: 1 } : {}}
          transition={{ duration: 0.8 }}
        >
          <div className="download-content">
            <motion.div
              className="download-text"
              initial={{ opacity: 0, x: -50 }}
              animate={inView ? { opacity: 1, x: 0 } : {}}
              transition={{ duration: 0.8, delay: 0.2 }}
            >
              <h2 className="download-title">
                Ready to Boost Your
                <br />
                <span className="gradient-text">Phone's Performance?</span>
              </h2>
              <p className="download-description">
                Join millions of satisfied users and experience the power of AI-driven phone optimization. Download now and get your first clean free!
              </p>
              
              <div className="download-buttons">
                <motion.button
                  className="download-btn playstore"
                  whileHover={{ scale: 1.05, y: -5 }}
                  whileTap={{ scale: 0.95 }}
                >
                  <div className="btn-icon">
                    <svg viewBox="0 0 24 24" fill="currentColor">
                      <path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.6 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.5,12.92 20.16,13.19L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z" />
                    </svg>
                  </div>
                  <div className="btn-text">
                    <span className="btn-small">GET IT ON</span>
                    <span className="btn-large">Google Play</span>
                  </div>
                </motion.button>

                <motion.button
                  className="download-btn appstore"
                  whileHover={{ scale: 1.05, y: -5 }}
                  whileTap={{ scale: 0.95 }}
                >
                  <div className="btn-icon">
                    <svg viewBox="0 0 24 24" fill="currentColor">
                      <path d="M18.71,19.5C17.88,20.74 17,21.95 15.66,21.97C14.32,22 13.89,21.18 12.37,21.18C10.84,21.18 10.37,21.95 9.1,22C7.79,22.05 6.8,20.68 5.96,19.47C4.25,17 2.94,12.45 4.7,9.39C5.57,7.87 7.13,6.91 8.82,6.88C10.1,6.86 11.32,7.75 12.11,7.75C12.89,7.75 14.37,6.68 15.92,6.84C16.57,6.87 18.39,7.1 19.56,8.82C19.47,8.88 17.39,10.1 17.41,12.63C17.44,15.65 20.06,16.66 20.09,16.67C20.06,16.74 19.67,18.11 18.71,19.5M13,3.5C13.73,2.67 14.94,2.04 15.94,2C16.07,3.17 15.6,4.35 14.9,5.19C14.21,6.04 13.07,6.7 11.95,6.61C11.8,5.46 12.36,4.26 13,3.5Z" />
                    </svg>
                  </div>
                  <div className="btn-text">
                    <span className="btn-small">Download on the</span>
                    <span className="btn-large">App Store</span>
                  </div>
                </motion.button>
              </div>

              <div className="download-stats">
                <div className="stat">
                  <span className="stat-icon">✓</span>
                  <span>100% Safe & Secure</span>
                </div>
                <div className="stat">
                  <span className="stat-icon">✓</span>
                  <span>No Ads, No Tracking</span>
                </div>
                <div className="stat">
                  <span className="stat-icon">✓</span>
                  <span>Free to Download</span>
                </div>
              </div>
            </motion.div>

            <motion.div
              className="download-visual"
              initial={{ opacity: 0, x: 50 }}
              animate={inView ? { opacity: 1, x: 0 } : {}}
              transition={{ duration: 0.8, delay: 0.4 }}
            >
              <div className="phone-mockup">
                <div className="phone-screen">
                  <div className="screen-content">
                    <motion.div
                      className="scan-animation"
                      animate={{
                        scale: [1, 1.2, 1],
                        opacity: [0.5, 1, 0.5],
                      }}
                      transition={{
                        duration: 2,
                        repeat: Infinity,
                        ease: "easeInOut",
                      }}
                    >
                      ⚡
                    </motion.div>
                  </div>
                </div>
              </div>
            </motion.div>
          </div>
        </motion.div>
      </div>

      <div className="gradient-blob download-blob-1 blob"></div>
      <div className="gradient-blob download-blob-2 blob"></div>
    </section>
  );
};

export default Download;
