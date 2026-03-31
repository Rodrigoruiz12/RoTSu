import React from 'react';
import { SectionHeading } from '../atoms/SectionHeading';
import { Button } from '../atoms/Button';
import { motion } from 'framer-motion';
import { Send } from 'lucide-react';

export const ContactSection: React.FC = () => {
  return (
    <section id="contacto" className="py-24 bg-[#1e1e1e] relative overflow-hidden">
      {/* Elemento decorativo */}
      <div className="absolute right-0 top-0 w-1/3 h-full bg-emerald-900/10 blur-[150px] pointer-events-none"></div>

      <div className="container mx-auto px-6 max-w-4xl relative z-10">
        <SectionHeading 
          title="Contáctanos" 
          subtitle="¿Listo para acelerar el crecimiento de tu empresa? Escríbenos y cuéntanos sobre tu próximo desafío tecnológico."
        />

        <motion.div 
          initial={{ opacity: 0, scale: 0.95 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="bg-[#252526] border border-[#333333] p-8 md:p-12 rounded-2xl md:mt-16 shadow-[0_0_40px_rgba(0,0,0,0.5)]"
        >
          <form className="space-y-6" onSubmit={(e) => e.preventDefault()}>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-gray-400 text-sm mb-2" htmlFor="name">Nombre</label>
                <input 
                  id="name"
                  type="text" 
                  className="w-full bg-[#1e1e1e] border border-[#333333] rounded-md px-4 py-3 text-white focus:outline-none focus:border-emerald-500 hover:border-[#555] transition-colors"
                  placeholder="Tu nombre o empresa"
                />
              </div>
              <div>
                <label className="block text-gray-400 text-sm mb-2" htmlFor="email">Correo Electrónico</label>
                <input 
                  id="email"
                  type="email" 
                  className="w-full bg-[#1e1e1e] border border-[#333333] rounded-md px-4 py-3 text-white focus:outline-none focus:border-emerald-500 hover:border-[#555] transition-colors"
                  placeholder="hola@ejemplo.com"
                />
              </div>
            </div>
            
            <div>
              <label className="block text-gray-400 text-sm mb-2" htmlFor="subject">Asunto</label>
              <input 
                id="subject"
                type="text" 
                className="w-full bg-[#1e1e1e] border border-[#333333] rounded-md px-4 py-3 text-white focus:outline-none focus:border-emerald-500 hover:border-[#555] transition-colors"
                placeholder="Ej. Diseño de Página Web"
              />
            </div>

            <div>
              <label className="block text-gray-400 text-sm mb-2" htmlFor="message">Mensaje</label>
              <textarea 
                id="message"
                rows={5}
                className="w-full bg-[#1e1e1e] border border-[#333333] rounded-md px-4 py-3 text-white focus:outline-none focus:border-emerald-500 hover:border-[#555] transition-colors resize-none"
                placeholder="Cuéntanos más detalles..."
              ></textarea>
            </div>

            <Button variant="primary" fullWidth className="flex justify-center items-center gap-2 mt-4 text-lg py-4">
              Enviar Mensaje <Send size={20} />
            </Button>
          </form>
        </motion.div>
      </div>
    </section>
  );
};
