import React from 'react';
import { SectionHeading } from '../atoms/SectionHeading';
import { ServicioCard } from '../molecules/ServicioCard';
import { Monitor, Smartphone, Database, Server, AppWindow, ShieldCheck } from 'lucide-react';

export const ServiciosGrid: React.FC = () => {
  const servicios = [
    {
      title: 'Páginas Web Modernas',
      description: 'Landing pages, sitios corporativos y e-commerce con rendimiento excepcional y diseño responsivo enfocado en conversión.',
      icon: <Monitor size={28} />
    },
    {
      title: 'Aplicaciones Móviles',
      description: 'Desarrollo para iOS y Android, creando experiencias de usuario fluidas y herramientas potentes para llevar en el bolsillo.',
      icon: <Smartphone size={28} />
    },
    {
      title: 'Sistemas a Medida',
      description: 'Plataformas personalizadas para gestión de stock, facturación y control de recursos empresariales ERP/CRM.',
      icon: <AppWindow size={28} />
    },
    {
      title: 'Gestión de Bases de Datos',
      description: 'Diseño, optimización y migración de arquitecturas de bases de datos relacionales y NoSQL altamente escalables.',
      icon: <Database size={28} />
    },
    {
      title: 'Infraestructura y DevOps',
      description: 'Despliegues en la nube (AWS/Azure/GCP), pipelines CI/CD y monitoreo 24/7 para alta disponibilidad y escalabilidad.',
      icon: <Server size={28} />
    },
    {
      title: 'Consultoría TI',
      description: 'Asesoramiento experto para transformar digitalmente tu negocio de la forma más eficiente, evaluando su arquitectura actual.',
      icon: <ShieldCheck size={28} />
    }
  ];

  return (
    <section id="servicios" className="py-24 bg-[#1a1a1b] relative">
      <div className="container mx-auto px-6 max-w-7xl relative z-10">
        <SectionHeading 
          title="Nuestros Servicios" 
          subtitle="Ofrecemos un espectro completo de soluciones de ingeniería de software para cubrir todas las necesidades tecnológicas de tu empresa."
        />
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-16">
          {servicios.map((srv, index) => (
            <ServicioCard 
              key={index}
              title={srv.title}
              description={srv.description}
              icon={srv.icon}
              delay={index * 0.1}
            />
          ))}
        </div>
      </div>
    </section>
  );
};
