import React from 'react';
import { motion } from 'framer-motion';
import { useInView } from 'react-intersection-observer';
import './Stats.css';

const statsData = [
  { value: '10M+', label: 'Downloads', icon: '📱' },
  { value: '4.8★', label: 'Rating', icon: '⭐' },
  { value: '500K+', label: '5-Star Reviews', icon: '❤️' },
  { value: '150+', label: 'Countries', icon: '🌍' },
];

const Stats = () => {
  const [ref, inView] = useInView({
    threshold: 0.3,
    triggerOnce: true,
  });

  return (
    <section className="stats">
      <div className="container">
        <div className="stats-grid" ref={ref}>
          {statsData.map((stat, index) => (
            <motion.div
              key={index}
              className="stat-box glass-card"
              initial={{ opacity: 0, scale: 0.8 }}
              animate={inView ? { opacity: 1, scale: 1 } : {}}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              whileHover={{ scale: 1.05 }}
            >
              <div className="stat-icon">{stat.icon}</div>
              <motion.div
                className="stat-value gradient-text"
                initial={{ opacity: 0 }}
                animate={inView ? { opacity: 1 } : {}}
                transition={{ duration: 0.8, delay: index * 0.1 + 0.3 }}
              >
                {stat.value}
              </motion.div>
              <div className="stat-label">{stat.label}</div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Stats;
