import React from 'react';
import { motion } from 'framer-motion';
import { useInView } from 'react-intersection-observer';
import './HowItWorks.css';

const steps = [
  {
    number: '01',
    title: 'Download & Install',
    description: 'Get the app from Play Store or App Store in seconds',
    icon: '📥',
  },
  {
    number: '02',
    title: 'Quick Scan',
    description: 'AI-powered scan analyzes your device in under 30 seconds',
    icon: '🔍',
  },
  {
    number: '03',
    title: 'Smart Clean',
    description: 'One-tap cleaning removes junk and optimizes performance',
    icon: '✨',
  },
  {
    number: '04',
    title: 'Enjoy Speed',
    description: 'Experience lightning-fast performance and extra storage',
    icon: '🚀',
  },
];

const HowItWorks = () => {
  const [ref, inView] = useInView({
    threshold: 0.1,
    triggerOnce: true,
  });

  return (
    <section className="how-it-works" id="how-it-works">
      <div className="container">
        <motion.div
          ref={ref}
          className="section-header"
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8 }}
        >
          <h2 className="section-title">
            Get Started in
            <span className="gradient-text"> 4 Simple Steps</span>
          </h2>
          <p className="section-description">
            Clean and optimize your phone in less than a minute
          </p>
        </motion.div>

        <div className="steps-container">
          {steps.map((step, index) => (
            <motion.div
              key={index}
              className="step-card glass-card"
              initial={{ opacity: 0, x: index % 2 === 0 ? -50 : 50 }}
              animate={inView ? { opacity: 1, x: 0 } : {}}
              transition={{ duration: 0.6, delay: index * 0.2 }}
            >
              <div className="step-number">{step.number}</div>
              <div className="step-icon">{step.icon}</div>
              <h3 className="step-title">{step.title}</h3>
              <p className="step-description">{step.description}</p>
              {index < steps.length - 1 && (
                <motion.div
                  className="step-connector"
                  initial={{ scaleX: 0 }}
                  animate={inView ? { scaleX: 1 } : {}}
                  transition={{ duration: 0.8, delay: index * 0.2 + 0.3 }}
                />
              )}
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default HowItWorks;
