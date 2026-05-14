import React from 'react';

interface SectionHeadingProps {
  title: string;
  subtitle?: string;
  centered?: boolean;
}

export const SectionHeading: React.FC<SectionHeadingProps> = ({ 
  title, 
  subtitle, 
  centered = true 
}) => {
  return (
    <div className={`mb-12 ${centered ? 'text-center' : 'text-left'}`}>
      <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
        {title}
        <span className="text-emerald-500">.</span>
      </h2>
      {subtitle && (
        <p className="text-gray-400 max-w-2xl mx-auto text-lg">
          {subtitle}
        </p>
      )}
      {/* Línea decorativa */}
      <div className={`h-1 w-20 bg-emerald-500 mt-6 ${centered ? 'mx-auto' : ''} rounded-full`}></div>
    </div>
  );
};
