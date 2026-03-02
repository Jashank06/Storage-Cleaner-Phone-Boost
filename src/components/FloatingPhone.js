import React, { useRef } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { OrbitControls, PerspectiveCamera, Environment } from '@react-three/drei';
import './FloatingPhone.css';

// 3D Phone Model Component
function PhoneModel() {
  const meshRef = useRef();
  
  useFrame((state) => {
    const t = state.clock.getElapsedTime();
    if (meshRef.current) {
      meshRef.current.rotation.y = Math.sin(t * 0.3) * 0.2;
      meshRef.current.position.y = Math.sin(t * 0.5) * 0.1;
    }
  });

  return (
    <group ref={meshRef}>
      {/* Phone body */}
      <mesh position={[0, 0, 0]}>
        <boxGeometry args={[1.5, 3, 0.15]} />
        <meshStandardMaterial
          color="#1a1a2e"
          metalness={0.9}
          roughness={0.1}
          envMapIntensity={1}
        />
      </mesh>
      
      {/* Screen */}
      <mesh position={[0, 0, 0.076]}>
        <boxGeometry args={[1.4, 2.9, 0.01]} />
        <meshStandardMaterial
          color="#667eea"
          emissive="#667eea"
          emissiveIntensity={0.5}
          metalness={0.5}
          roughness={0.2}
        />
      </mesh>

      {/* Camera notch */}
      <mesh position={[0, 1.3, 0.076]}>
        <boxGeometry args={[0.3, 0.1, 0.02]} />
        <meshStandardMaterial color="#0a0a0f" />
      </mesh>

      {/* Side buttons */}
      <mesh position={[0.76, 0.5, 0]}>
        <boxGeometry args={[0.02, 0.3, 0.1]} />
        <meshStandardMaterial color="#667eea" metalness={0.8} roughness={0.2} />
      </mesh>
    </group>
  );
}

const FloatingPhone = () => {
  return (
    <div className="floating-phone-container">
      <Canvas>
        <PerspectiveCamera makeDefault position={[0, 0, 5]} />
        <ambientLight intensity={0.5} />
        <spotLight position={[10, 10, 10]} angle={0.15} penumbra={1} intensity={1} />
        <pointLight position={[-10, -10, -10]} intensity={0.5} />
        <PhoneModel />
        <Environment preset="city" />
        <OrbitControls
          enableZoom={false}
          enablePan={false}
          autoRotate
          autoRotateSpeed={2}
          maxPolarAngle={Math.PI / 2}
          minPolarAngle={Math.PI / 2}
        />
      </Canvas>
      
      {/* Glow effect */}
      <div className="phone-glow"></div>
    </div>
  );
};

export default FloatingPhone;
