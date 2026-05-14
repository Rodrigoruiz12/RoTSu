import React from 'react';
import { SectionHeading } from '../atoms/SectionHeading';
import { motion } from 'framer-motion';
import { Code2, Cpu } from 'lucide-react';

export const AboutUsSection: React.FC = () => {
  return (
    <section id="about" className="py-24 bg-[#1a1a1b]">
      <div className="container mx-auto px-6 max-w-7xl">
        <div className="flex flex-col lg:flex-row items-center gap-16">
          
          <motion.div 
            initial={{ opacity: 0, x: -50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="lg:w-1/2"
          >
            <div className="relative">
              <div className="absolute -inset-4 bg-emerald-500/20 blur-xl rounded-full"></div>
              <div className="bg-[#252526] border border-[#333333] p-10 rounded-2xl relative z-10">
                <div className="flex items-center gap-4 mb-8">
                  <div className="w-16 h-16 bg-[#1e1e1e] rounded-xl flex items-center justify-center text-emerald-500 border border-[#333333]">
                     <Code2 size={32} />
                  </div>
                  <div className="w-16 h-16 bg-[#1e1e1e] rounded-xl flex items-center justify-center text-emerald-500 border border-[#333333]">
                     <Cpu size={32} />
                  </div>
                </div>
                <h3 className="text-2xl font-bold text-white mb-4">Transformando código en valor</h3>
                <p className="text-gray-400 mb-6 leading-relaxed">
                  En RoTSu, somos más que desarrolladores; somos tus socios tecnológicos estratégicos. Nos apasiona construir arquitecturas sólidas, interfaces intuitivas y sistemas que resuelvan problemas reales.
                </p>
                <div className="grid grid-cols-2 gap-6 mt-8">
                  <div>
                    <h4 className="text-3xl font-bold text-emerald-500 mb-2">+50</h4>
                    <p className="text-sm text-gray-500">Proyectos exitosos</p>
                  </div>
                  <div>
                    <h4 className="text-3xl font-bold text-emerald-500 mb-2">100%</h4>
                    <p className="text-sm text-gray-500">Compromiso</p>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>

          <motion.div 
            initial={{ opacity: 0, x: 50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="lg:w-1/2"
          >
            <SectionHeading 
              title="Sobre Nosotros" 
              subtitle="Un equipo de expertos apasionados por la tecnología y la innovación."
              centered={false}
            />
            
            <div className="space-y-8 mt-8">
               <div className="flex gap-6">
                 <div className="flex-shrink-0 w-2 h-full bg-emerald-500 rounded-full min-h-[50px]"></div>
                 <div>
                   <h4 className="text-xl font-bold text-white mb-2">Nuestra Misión</h4>
                   <p className="text-gray-400 leading-relaxed">
                     Digitalizar y optimizar los procesos de pequeñas y medianas empresas mediante soluciones de software vanguardistas, escalables y elegantes.
                   </p>
                 </div>
               </div>
               
               <div className="flex gap-6">
                 <div className="flex-shrink-0 w-2 h-full bg-[#333333] rounded-full min-h-[50px]"></div>
                 <div>
                   <h4 className="text-xl font-bold text-white mb-2">Metodología Ágil</h4>
                   <p className="text-gray-400 leading-relaxed">
                     Utilizamos flujos de trabajo eficientes (GitFlow, Scrum) para asegurar entregas rápidas sin sacrificar la calidad técnica ni el diseño.
                   </p>
                 </div>
               </div>
            </div>
          </motion.div>

        </div>
      </div>
    </section>
  );
};
