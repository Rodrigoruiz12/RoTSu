import React from 'react';
import { motion } from 'framer-motion';
import { ExternalLink } from 'lucide-react';

interface PortafolioCardProps {
  title: string;
  category: string;
  imageUrl?: string;
  delay?: number;
}

export const PortafolioCard: React.FC<PortafolioCardProps> = ({
  title,
  category,
  imageUrl,
  delay = 0
}) => {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.9 }}
      whileInView={{ opacity: 1, scale: 1 }}
      viewport={{ once: true, margin: "-50px" }}
      transition={{ duration: 0.5, delay }}
      className="group relative rounded-xl overflow-hidden border border-[#333333] cursor-pointer bg-[#252526] hover:shadow-[0_0_25px_rgba(16,185,129,0.1)] transition-shadow"
    >
      {/* Imagen o Placeholder */}
      <div className="h-56 md:h-64 w-full bg-[#1e1e1e] relative overflow-hidden border-b border-[#333333]">
        {imageUrl ? (
          <img 
            src={imageUrl} 
            alt={title} 
            className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700"
          />
        ) : (
          <div className="w-full h-full flex flex-col items-center justify-center text-[#444444] group-hover:scale-110 group-hover:text-emerald-500/30 transition-all duration-700">
             <div className="math-logo-container opacity-20 mb-2">
               <div className="math-shape"></div>
               <div className="math-shape"></div>
             </div>
          </div>
        )}
        
        {/* Overlay oscuro al interactuar */}
        <div className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center justify-center">
          <div className="w-12 h-12 bg-emerald-500 rounded-full flex items-center justify-center transform translate-y-4 group-hover:translate-y-0 transition-all duration-300">
            <ExternalLink className="text-white" size={24} />
          </div>
        </div>
      </div>
      
      {/* Contenido */}
      <div className="p-5 group-hover:border-emerald-500/50 transition-colors">
        <span className="text-emerald-500 text-xs md:text-sm font-semibold mb-1 block uppercase tracking-wider">
          {category}
        </span>
        <h3 className="text-lg md:text-xl font-bold text-white">
          {title}
        </h3>
      </div>
    </motion.div>
  );
};
