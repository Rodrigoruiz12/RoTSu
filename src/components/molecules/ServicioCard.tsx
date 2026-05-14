import React from 'react';
import { motion } from 'framer-motion';

interface ServicioCardProps {
  title: string;
  description: string;
  icon: React.ReactNode;
  delay?: number;
}

export const ServicioCard: React.FC<ServicioCardProps> = ({ 
  title, 
  description, 
  icon,
  delay = 0
}) => {
  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-50px" }}
      transition={{ duration: 0.5, delay }}
      className="bg-[#252526] border border-[#333333] p-6 rounded-xl hover:border-emerald-500 transition-all duration-300 group hover:shadow-[0_0_20px_rgba(16,185,129,0.15)]"
    >
      <div className="text-emerald-500 mb-4 bg-[#1e1e1e] w-14 h-14 rounded-lg flex items-center justify-center group-hover:scale-110 transition-transform duration-300 shadow-inner">
        {icon}
      </div>
      <h3 className="text-xl font-bold text-white mb-3 group-hover:text-emerald-400 transition-colors">
        {title}
      </h3>
      <p className="text-gray-400 leading-relaxed text-sm md:text-base">
        {description}
      </p>
    </motion.div>
  );
};
