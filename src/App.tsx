import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { MainLayout } from './components/templates/MainLayout';
import { Inicio } from './pages/Inicio';
import { Servicios } from './pages/Servicios';
import { SobreNosotros } from './pages/SobreNosotros';
import { Portafolio } from './pages/Portafolio';
import { Contacto } from './pages/Contacto';

export const App = () => {
  return (
    <BrowserRouter>
      <MainLayout>
        <Routes>
          <Route path="/" element={<Inicio />} />
          <Route path="/servicios" element={<Servicios />} />
          <Route path="/sobre-nosotros" element={<SobreNosotros />} />
          <Route path="/portafolio" element={<Portafolio />} />
          <Route path="/contacto" element={<Contacto />} />
        </Routes>
      </MainLayout>
    </BrowserRouter>
  );
};
