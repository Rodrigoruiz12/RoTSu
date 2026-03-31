import React from 'react';

interface LogoProps {
  className?: string;
}

export const Logo: React.FC<LogoProps> = ({ className = '' }) => {
  return (
    <div className={`flex items-center gap-3 ${className}`}>
      {/* Logo generado con Matemáticas y CSS */}
      <div className="math-logo-container" aria-hidden="true">
        <div className="math-shape"></div>
        <div className="math-shape"></div>
        <div className="math-shape"></div>
      </div>
      
      {/* Texto del Logo */}
      <span className="text-xl font-bold tracking-wider text-white">
        RoTSu
        <span className="text-emerald-500 text-2xl leading-none">.</span>
      </span>
    </div>
  );
};
