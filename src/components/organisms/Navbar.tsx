import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Logo } from '../atoms/Logo';
import { NavLinks } from '../molecules/NavLinks';
import { Menu, X } from 'lucide-react';
import { Button } from '../atoms/Button';

export const Navbar: React.FC = () => {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 50);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <header 
      className={`fixed top-0 w-full z-50 transition-all duration-300 ${
        isScrolled ? 'bg-[#1e1e1e]/90 backdrop-blur-md shadow-lg py-3' : 'bg-transparent py-5'
      }`}
    >
      <div className="container mx-auto px-6 max-w-7xl flex items-center justify-between">
        <Link to="/"><Logo /></Link>
        
        {/* Desktop Nav */}
        <div className="hidden md:flex items-center gap-8">
          <NavLinks className="gap-8" />
          <Link to="/contacto">
            <Button variant="outline" className="px-5 py-2 text-sm">
              Hablemos
            </Button>
          </Link>
        </div>

        {/* Mobile Toggle */}
        <button 
          className="md:hidden text-white hover:text-emerald-500 transition-colors"
          onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
        >
          {isMobileMenuOpen ? <X size={28} /> : <Menu size={28} />}
        </button>
      </div>

      {/* Mobile Nav */}
      {isMobileMenuOpen && (
        <div className="md:hidden absolute top-full left-0 w-full bg-[#1e1e1e] border-t border-[#333333] shadow-xl p-6 flex flex-col gap-6">
          <NavLinks 
            className="flex-col gap-4 text-center items-center text-lg" 
            onClick={() => setIsMobileMenuOpen(false)} 
          />
          <Link to="/contacto" onClick={() => setIsMobileMenuOpen(false)}>
            <Button variant="primary" fullWidth>
              Hablemos
            </Button>
          </Link>
        </div>
      )}
    </header>
  );
};
