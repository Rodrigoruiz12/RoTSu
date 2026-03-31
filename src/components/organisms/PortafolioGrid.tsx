import React from 'react';
import { SectionHeading } from '../atoms/SectionHeading';
import { PortafolioCard } from '../molecules/PortafolioCard';

export const PortafolioGrid: React.FC = () => {
  const proyectos = [
    {
      title: 'Plataforma E-commerce Muebles',
      category: 'Desarrollo Web',
      imageUrl: '' // Vacio para ver el placeholder math/css
    },
    {
      title: 'App Gestión Logística',
      category: 'Aplicación Móvil',
      imageUrl: '' 
    },
    {
      title: 'Sistema ERP Textil',
      category: 'Sistema a Medida',
      imageUrl: '' 
    },
    {
      title: 'Migración Cloud Bancaria',
      category: 'Infraestructura',
      imageUrl: '' 
    }
  ];

  return (
    <section id="portafolio" className="py-24 bg-[#1e1e1e]">
      <div className="container mx-auto px-6 max-w-7xl">
        <SectionHeading 
          title="Casos de Éxito" 
          subtitle="Conoce algunos de los proyectos en los que hemos ayudado a empresas a alcanzar sus objetivos tecnológicos."
        />
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mt-16">
          {proyectos.map((proj, index) => (
            <PortafolioCard 
              key={index}
              title={proj.title}
              category={proj.category}
              imageUrl={proj.imageUrl}
              delay={index * 0.15}
            />
          ))}
        </div>
      </div>
    </section>
  );
};
