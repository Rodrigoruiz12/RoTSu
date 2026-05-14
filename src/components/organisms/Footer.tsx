import React from 'react';
import { Link } from 'react-router-dom';
import { Logo } from '../atoms/Logo';
import { Globe, MessageCircle, Briefcase, Mail } from 'lucide-react';

export const Footer: React.FC = () => {
  return (
    <footer className="bg-[#1a1a1b] pt-16 pb-8 border-t border-[#333333]">
      <div className="container mx-auto px-6 max-w-7xl">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-10 mb-12">
          
          <div className="md:col-span-2">
            <Logo className="mb-6" />
            <p className="text-gray-400 max-w-md mb-6 leading-relaxed">
              Soluciones tecnológicas elegantes y robustas. 
              Impulsamos el crecimiento de tu empresa a través del software de alta calidad.
            </p>
            <div className="flex gap-4">
              <a href="#" className="w-10 h-10 rounded-full bg-[#252526] flex items-center justify-center text-gray-400 hover:text-emerald-500 hover:bg-[#333333] transition-colors">
                <Globe size={20} />
              </a>
              <a href="#" className="w-10 h-10 rounded-full bg-[#252526] flex items-center justify-center text-gray-400 hover:text-emerald-500 hover:bg-[#333333] transition-colors">
                <MessageCircle size={20} />
              </a>
              <a href="#" className="w-10 h-10 rounded-full bg-[#252526] flex items-center justify-center text-gray-400 hover:text-emerald-500 hover:bg-[#333333] transition-colors">
                <Briefcase size={20} />
              </a>
            </div>
          </div>
          
          <div>
            <h4 className="text-white font-bold mb-6">Enlaces Rápidos</h4>
            <ul className="flex flex-col gap-3">
              <li><Link to="/" className="text-gray-400 hover:text-emerald-500 transition-colors">Inicio</Link></li>
              <li><Link to="/servicios" className="text-gray-400 hover:text-emerald-500 transition-colors">Servicios</Link></li>
              <li><Link to="/sobre-nosotros" className="text-gray-400 hover:text-emerald-500 transition-colors">Sobre Nosotros</Link></li>
              <li><Link to="/portafolio" className="text-gray-400 hover:text-emerald-500 transition-colors">Portafolio</Link></li>
              <li><Link to="/contacto" className="text-gray-400 hover:text-emerald-500 transition-colors">Contacto</Link></li>
            </ul>
          </div>
          
          <div>
            <h4 className="text-white font-bold mb-6">Contacto</h4>
            <ul className="flex flex-col gap-3">
              <li className="flex items-center gap-3 text-gray-400">
                <Mail size={16} className="text-emerald-500" />
                contacto@rotsu.com
              </li>
              <li className="text-gray-400 mt-4">
                Lunes a Viernes<br/>
                9:00 AM - 6:00 PM
              </li>
            </ul>
          </div>

        </div>
        
        <div className="border-t border-[#333333] pt-8 flex flex-col md:flex-row items-center justify-between text-gray-500 text-sm">
          <p>&copy; {new Date().getFullYear()} RoTSu. Todos los derechos reservados ©.</p>
          <div className="flex gap-4 mt-4 md:mt-0">
            <a href="#" className="hover:text-emerald-400 transition-colors">Privacidad</a>
            <a href="#" className="hover:text-emerald-400 transition-colors">Términos</a>
          </div>
        </div>
      </div>
    </footer>
  );
};
