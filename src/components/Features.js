import React from 'react';
import { motion } from 'framer-motion';
import { useInView } from 'react-intersection-observer';
import './Features.css';

const featuresData = [
  {
    icon: '🧹',
    title: 'Junk File Cleaner',
    description: 'Remove cache, temp files, and unnecessary data to free up valuable storage space instantly.',
    gradient: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
  },
  {
    icon: '⚡',
    title: 'RAM Booster',
    description: 'Optimize memory usage and close background apps for lightning-fast performance.',
    gradient: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
  },
  {
    icon: '🔍',
    title: 'Duplicate Finder',
    description: 'Detect and remove duplicate photos, videos, and files with smart AI recognition.',
    gradient: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
  },
  {
    icon: '📱',
    title: 'WhatsApp Cleaner',
    description: 'Clean WhatsApp media, old chats, and duplicates to save gigabytes of storage.',
    gradient: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
  },
  {
    icon: '📊',
    title: 'Storage Analyzer',
    description: 'Visual breakdown of storage usage with detailed insights and recommendations.',
    gradient: 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
  },
  {
    icon: '🔋',
    title: 'Battery Saver',
    description: 'Extend battery life by optimizing power-hungry apps and background processes.',
    gradient: 'linear-gradient(135deg, #30cfd0 0%, #330867 100%)',
  },
];

const FeatureCard = ({ feature, index }) => {
  const [ref, inView] = useInView({
    threshold: 0.2,
    triggerOnce: true,
  });

  return (
    <motion.div
      ref={ref}
      className="feature-card glass-card"
      initial={{ opacity: 0, y: 50 }}
      animate={inView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.6, delay: index * 0.1 }}
      whileHover={{ y: -10 }}
    >
      <motion.div
        className="feature-icon"
        style={{ background: feature.gradient }}
        whileHover={{ rotate: 360 }}
        transition={{ duration: 0.6 }}
      >
        {feature.icon}
      </motion.div>
      <h3 className="feature-title">{feature.title}</h3>
      <p className="feature-description">{feature.description}</p>
      
      <motion.div
        className="feature-arrow"
        initial={{ x: 0 }}
        whileHover={{ x: 5 }}
      >
        →
      </motion.div>
    </motion.div>
  );
};

const Features = () => {
  const [ref, inView] = useInView({
    threshold: 0.1,
    triggerOnce: true,
  });

  return (
    <section className="features" id="features">
      <div className="container">
        <motion.div
          ref={ref}
          className="features-header"
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8 }}
        >
          <h2 className="section-title">
            Powerful Features for
            <br />
            <span className="gradient-text">Ultimate Performance</span>
          </h2>
          <p className="section-description">
            Everything you need to keep your phone running at peak performance
          </p>
        </motion.div>

        <div className="features-grid">
          {featuresData.map((feature, index) => (
            <FeatureCard key={index} feature={feature} index={index} />
          ))}
        </div>
      </div>
    </section>
  );
};

export default Features;
