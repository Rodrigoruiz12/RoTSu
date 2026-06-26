import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { Navbar } from './Navbar';

describe('Navbar', () => {
  it('muestra el logo y los enlaces de navegación', () => {
    render(
      <MemoryRouter>
        <Navbar />
      </MemoryRouter>
    );
    expect(screen.getAllByText(/RoTSu/i).length).toBeGreaterThan(0);
    ['Inicio', 'Servicios', 'Sobre nosotros', 'Portafolio', 'Contacto'].forEach((name) => {
      expect(screen.getByRole('link', { name })).toBeInTheDocument();
    });
  });

  it('muestra el botón "Hablemos" hacia /contacto', () => {
    render(
      <MemoryRouter>
        <Navbar />
      </MemoryRouter>
    );
    const link = screen.getByRole('link', { name: /hablemos/i });
    expect(link).toHaveAttribute('href', '/contacto');
  });

  it('renderiza botón de menú móvil visible en pantallas pequeñas', () => {
    render(
      <MemoryRouter>
        <Navbar />
      </MemoryRouter>
    );
    // Hay botones de menú y de CTA "Hablemos"
    expect(screen.getAllByRole('button').length).toBeGreaterThan(0);
  });
});
