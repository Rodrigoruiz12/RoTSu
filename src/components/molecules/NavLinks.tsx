import React from 'react';
import { Link } from 'react-router-dom';

const LINKS = [
  { name: 'Inicio', href: '/' },
  { name: 'Servicios', href: '/servicios' },
  { name: 'Sobre nosotros', href: '/sobre-nosotros' },
  { name: 'Portafolio', href: '/portafolio' },
  { name: 'Contacto', href: '/contacto' },
];

interface NavLinksProps {
  className?: string;
  onClick?: () => void;
}

export const NavLinks: React.FC<NavLinksProps> = ({ className = '', onClick }) => {
  return (
    <ul className={`flex ${className}`}>
      {LINKS.map((link) => (
        <li key={link.name}>
          <Link
            to={link.href}
            onClick={onClick}
            className="text-gray-300 hover:text-emerald-400 font-medium transition-colors duration-300 block py-2"
          >
            {link.name}
          </Link>
        </li>
      ))}
    </ul>
  );
};
