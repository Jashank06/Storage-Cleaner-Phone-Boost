import React, { useEffect, useRef } from 'react';
import './ParticlesBackground.css';

const ParticlesBackground = ({ lowPower = false }) => {
  const canvasRef = useRef(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    const resizeCanvas = () => {
      const dpr = Math.min(window.devicePixelRatio || 1, lowPower ? 1.2 : 2);
      canvas.width = window.innerWidth * dpr;
      canvas.height = window.innerHeight * dpr;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    };

    resizeCanvas();

    const particles = [];
    const particleCount = lowPower ? 35 : 80;
    const maxDistance = lowPower ? 110 : 150;
    const targetFrameTime = lowPower ? 1000 / 30 : 0;
    let lastFrameTime = 0;
    let animationFrameId;
    let isVisible = !document.hidden;

    class Particle {
      constructor() {
        this.x = Math.random() * canvas.width;
        this.y = Math.random() * canvas.height;
        this.size = Math.random() * (lowPower ? 2 : 3) + 1;
        const speedScale = lowPower ? 0.4 : 1;
        this.speedX = (Math.random() * 1 - 0.5) * speedScale;
        this.speedY = (Math.random() * 1 - 0.5) * speedScale;
        this.opacity = Math.random() * 0.5 + 0.2;
      }

      update() {
        this.x += this.speedX;
        this.y += this.speedY;

        if (this.x > canvas.width) this.x = 0;
        if (this.x < 0) this.x = canvas.width;
        if (this.y > canvas.height) this.y = 0;
        if (this.y < 0) this.y = canvas.height;
      }

      draw() {
        ctx.fillStyle = `rgba(102, 126, 234, ${this.opacity})`;
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx.fill();
      }
    }

    for (let i = 0; i < particleCount; i++) {
      particles.push(new Particle());
    }

    function connectParticles() {
      for (let i = 0; i < particles.length; i++) {
        for (let j = i + 1; j < particles.length; j++) {
          const dx = particles[i].x - particles[j].x;
          const dy = particles[i].y - particles[j].y;
          const distance = Math.sqrt(dx * dx + dy * dy);

          if (distance < maxDistance) {
            ctx.strokeStyle = `rgba(102, 126, 234, ${0.1 * (1 - distance / maxDistance)})`;
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(particles[i].x, particles[i].y);
            ctx.lineTo(particles[j].x, particles[j].y);
            ctx.stroke();
          }
        }
      }
    }

    function animate(time) {
      animationFrameId = requestAnimationFrame(animate);

      if (!isVisible) {
        return;
      }

      if (targetFrameTime && time - lastFrameTime < targetFrameTime) {
        return;
      }

      lastFrameTime = time;
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      particles.forEach(particle => {
        particle.update();
        particle.draw();
      });

      connectParticles();
    }

    const handleVisibility = () => {
      isVisible = !document.hidden;
    };

    animate(0);

    window.addEventListener('resize', resizeCanvas);
    document.addEventListener('visibilitychange', handleVisibility);

    return () => {
      window.removeEventListener('resize', resizeCanvas);
      document.removeEventListener('visibilitychange', handleVisibility);
      if (animationFrameId) {
        cancelAnimationFrame(animationFrameId);
      }
    };
  }, [lowPower]);

  return <canvas ref={canvasRef} className="particles-canvas" />;
};

export default ParticlesBackground;
