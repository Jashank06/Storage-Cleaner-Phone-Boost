import React from 'react';
import { motion } from 'framer-motion';
import { useInView } from 'react-intersection-observer';
import './Testimonials.css';

const testimonialsData = [
  {
    name: 'Sarah Johnson',
    role: 'Tech Enthusiast',
    image: '👩‍💼',
    rating: 5,
    text: 'This app is a game-changer! My phone feels brand new. Freed up 3GB of storage in just one tap!',
  },
  {
    name: 'Michael Chen',
    role: 'Professional Photographer',
    image: '👨‍💻',
    rating: 5,
    text: 'The duplicate finder is incredible. It found hundreds of duplicate photos I didn\'t even know I had.',
  },
  {
    name: 'Emma Williams',
    role: 'Small Business Owner',
    image: '👩‍💼',
    rating: 5,
    text: 'My phone was constantly running out of space. This app solved all my storage problems instantly!',
  },
  {
    name: 'David Martinez',
    role: 'Mobile Gamer',
    image: '👨‍🎮',
    rating: 5,
    text: 'The RAM boost feature is amazing! My games run so much smoother now. Highly recommend!',
  },
  {
    name: 'Lisa Anderson',
    role: 'Content Creator',
    image: '👩‍🎨',
    rating: 5,
    text: 'WhatsApp cleaner is a lifesaver! Cleared gigabytes of old media. Best cleaner app I\'ve used!',
  },
  {
    name: 'James Taylor',
    role: 'Student',
    image: '👨‍🎓',
    rating: 5,
    text: 'Simple, fast, and effective. My old phone feels like new again. The UI is beautiful too!',
  },
];

const Testimonials = () => {
  const [ref, inView] = useInView({
    threshold: 0.1,
    triggerOnce: true,
  });

  return (
    <section className="testimonials" id="testimonials">
      <div className="container">
        <motion.div
          ref={ref}
          className="section-header"
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8 }}
        >
          <h2 className="section-title">
            Loved by
            <span className="gradient-text"> Millions Worldwide</span>
          </h2>
          <p className="section-description">
            See what our users have to say about their experience
          </p>
        </motion.div>

        <div className="testimonials-grid">
          {testimonialsData.map((testimonial, index) => (
            <motion.div
              key={index}
              className="testimonial-card glass-card"
              initial={{ opacity: 0, y: 50 }}
              animate={inView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.6, delay: index * 0.1 }}
              whileHover={{ y: -10 }}
            >
              <div className="testimonial-rating">
                {[...Array(testimonial.rating)].map((_, i) => (
                  <span key={i} className="star">⭐</span>
                ))}
              </div>
              <p className="testimonial-text">"{testimonial.text}"</p>
              <div className="testimonial-author">
                <div className="author-image">{testimonial.image}</div>
                <div className="author-info">
                  <div className="author-name">{testimonial.name}</div>
                  <div className="author-role">{testimonial.role}</div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Testimonials;
