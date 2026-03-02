import React from 'react';
import { motion } from 'framer-motion';
import { useInView } from 'react-intersection-observer';
import './PrivacyPolicy.css';

const PrivacyPolicy = () => {
  const [ref, inView] = useInView({
    threshold: 0.1,
    triggerOnce: true,
  });

  const sections = [
    {
      title: "1. Information We Collect",
      icon: "📊",
      content: [
        {
          subtitle: "Device Information",
          text: "We collect information about your device including model, operating system version, storage capacity, and app usage patterns to provide accurate cleaning recommendations."
        },
        {
          subtitle: "Usage Data",
          text: "We collect anonymous usage statistics to improve app performance, including scan frequency, features used, and storage cleaned."
        },
        {
          subtitle: "Analytics",
          text: "We use industry-standard analytics tools to understand how users interact with our app and identify areas for improvement."
        }
      ]
    },
    {
      title: "2. How We Use Your Information",
      icon: "🔧",
      content: [
        {
          subtitle: "App Functionality",
          text: "Your device data is used solely to provide cleaning and optimization services. We analyze storage patterns to identify junk files, duplicates, and unused data."
        },
        {
          subtitle: "Performance Improvement",
          text: "Anonymous usage data helps us optimize features, fix bugs, and develop new functionality based on user needs."
        },
        {
          subtitle: "Personalization",
          text: "We use your app preferences to customize your experience and provide relevant cleaning recommendations."
        }
      ]
    },
    {
      title: "3. Data Storage & Security",
      icon: "🔒",
      content: [
        {
          subtitle: "Local Processing",
          text: "All scanning and cleaning operations are performed locally on your device. Your personal files never leave your phone."
        },
        {
          subtitle: "Encryption",
          text: "Any data transmitted to our servers is encrypted using industry-standard SSL/TLS protocols to ensure maximum security."
        },
        {
          subtitle: "No File Storage",
          text: "We do not store, backup, or access your personal files, photos, videos, or documents. All cleaning operations are immediate and local."
        }
      ]
    },
    {
      title: "4. Third-Party Services",
      icon: "🔗",
      content: [
        {
          subtitle: "Analytics Providers",
          text: "We use Google Analytics and Firebase to collect anonymous usage statistics. These services are GDPR and CCPA compliant."
        },
        {
          subtitle: "Advertising",
          text: "We may display ads from trusted partners. Advertisers do not receive access to your personal information or device files."
        },
        {
          subtitle: "No Data Selling",
          text: "We never sell, rent, or share your personal information with third parties for marketing purposes."
        }
      ]
    },
    {
      title: "5. Your Rights & Controls",
      icon: "⚙️",
      content: [
        {
          subtitle: "Access & Deletion",
          text: "You can request access to your data or request deletion at any time through the app settings or by contacting us."
        },
        {
          subtitle: "Opt-Out",
          text: "You can opt-out of analytics and personalized recommendations in the app settings without affecting core functionality."
        },
        {
          subtitle: "Data Portability",
          text: "You have the right to request a copy of your data in a machine-readable format as per GDPR requirements."
        }
      ]
    },
    {
      title: "6. Children's Privacy",
      icon: "👶",
      content: [
        {
          subtitle: "Age Restriction",
          text: "Our app is not intended for children under 13. We do not knowingly collect information from children."
        },
        {
          subtitle: "Parental Control",
          text: "If you believe your child has provided information to us, please contact us immediately for removal."
        }
      ]
    },
    {
      title: "7. Permissions We Request",
      icon: "🔐",
      content: [
        {
          subtitle: "Storage Access",
          text: "Required to scan and clean junk files, duplicates, and temporary data on your device."
        },
        {
          subtitle: "App Usage Stats",
          text: "To identify rarely used apps and provide RAM optimization recommendations."
        },
        {
          subtitle: "Network Access",
          text: "Used for analytics, updates, and displaying ads. No personal files are uploaded."
        }
      ]
    },
    {
      title: "8. International Data Transfers",
      icon: "🌍",
      content: [
        {
          subtitle: "Global Services",
          text: "Our servers may be located in different countries. We ensure all transfers comply with applicable data protection laws."
        },
        {
          subtitle: "EU-US Privacy Shield",
          text: "For European users, we comply with GDPR and ensure adequate safeguards for data transfers."
        }
      ]
    },
    {
      title: "9. Updates to This Policy",
      icon: "📝",
      content: [
        {
          subtitle: "Notification",
          text: "We will notify you of significant changes to this privacy policy through the app or email."
        },
        {
          subtitle: "Effective Date",
          text: "This policy is effective as of January 1, 2024. Continued use after changes indicates acceptance."
        }
      ]
    },
    {
      title: "10. Contact Us",
      icon: "📧",
      content: [
        {
          subtitle: "Questions & Concerns",
          text: "If you have any questions about this privacy policy or our data practices, please contact us at:"
        },
        {
          subtitle: "Email",
          text: "privacy@smartcleaner.app"
        },
        {
          subtitle: "Support",
          text: "support@smartcleaner.app"
        },
        {
          subtitle: "Address",
          text: "SmartCleaner Inc., 123 Tech Street, San Francisco, CA 94105, USA"
        }
      ]
    }
  ];

  return (
    <div className="privacy-policy-page">
      {/* Hero Section */}
      <section className="privacy-hero">
        <div className="container">
          <motion.div
            className="privacy-hero-content"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            <motion.div
              className="privacy-icon"
              animate={{ rotate: [0, 10, -10, 0] }}
              transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
            >
              🔒
            </motion.div>
            <h1 className="privacy-title">
              Privacy <span className="gradient-text">Policy</span>
            </h1>
            <p className="privacy-subtitle">
              Your privacy is our top priority. Learn how we protect your data.
            </p>
            <div className="privacy-meta">
              <div className="meta-item">
                <span className="meta-icon">📅</span>
                <span>Last Updated: January 1, 2024</span>
              </div>
              <div className="meta-item">
                <span className="meta-icon">⏱️</span>
                <span>5 min read</span>
              </div>
            </div>
          </motion.div>
        </div>
        <div className="gradient-blob privacy-blob-1 blob"></div>
        <div className="gradient-blob privacy-blob-2 blob"></div>
      </section>

      {/* Key Points Section */}
      <section className="privacy-highlights">
        <div className="container">
          <div className="highlights-grid">
            <motion.div
              className="highlight-card glass-card"
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
            >
              <div className="highlight-icon">🛡️</div>
              <h3>Your Data Stays Local</h3>
              <p>All cleaning operations happen on your device. We never upload your files.</p>
            </motion.div>
            <motion.div
              className="highlight-card glass-card"
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.3 }}
            >
              <div className="highlight-icon">🚫</div>
              <h3>No Data Selling</h3>
              <p>We never sell your personal information to third parties. Period.</p>
            </motion.div>
            <motion.div
              className="highlight-card glass-card"
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.4 }}
            >
              <div className="highlight-icon">🔐</div>
              <h3>Bank-Level Security</h3>
              <p>Industry-standard encryption protects all data transmissions.</p>
            </motion.div>
            <motion.div
              className="highlight-card glass-card"
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.5 }}
            >
              <div className="highlight-icon">✅</div>
              <h3>Full Control</h3>
              <p>Access, export, or delete your data anytime from app settings.</p>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Main Content */}
      <section className="privacy-content" ref={ref}>
        <div className="container">
          <div className="content-wrapper">
            {sections.map((section, index) => (
              <motion.div
                key={index}
                className="privacy-section glass-card"
                initial={{ opacity: 0, y: 50 }}
                animate={inView ? { opacity: 1, y: 0 } : {}}
                transition={{ duration: 0.6, delay: index * 0.1 }}
              >
                <div className="section-header">
                  <div className="section-icon">{section.icon}</div>
                  <h2 className="section-title">{section.title}</h2>
                </div>
                <div className="section-content">
                  {section.content.map((item, i) => (
                    <div key={i} className="content-block">
                      <h3 className="content-subtitle gradient-text-accent">
                        {item.subtitle}
                      </h3>
                      <p className="content-text">{item.text}</p>
                    </div>
                  ))}
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="privacy-cta">
        <div className="container">
          <motion.div
            className="cta-card glass-card"
            initial={{ opacity: 0, scale: 0.9 }}
            whileInView={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.6 }}
            viewport={{ once: true }}
          >
            <h2 className="cta-title">
              Have Questions About Your <span className="gradient-text">Privacy?</span>
            </h2>
            <p className="cta-text">
              Our privacy team is here to help. Reach out anytime with your concerns.
            </p>
            <div className="cta-buttons">
              <motion.button
                className="btn-primary"
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
              >
                Contact Support
              </motion.button>
              <motion.button
                className="btn-secondary"
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
              >
                View Terms of Service
              </motion.button>
            </div>
          </motion.div>
        </div>
      </section>
    </div>
  );
};

export default PrivacyPolicy;
