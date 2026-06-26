import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { Footer } from './Footer';

describe('Footer', () => {
  it('muestra el email de contacto', () => {
    render(
      <MemoryRouter>
        <Footer />
      </MemoryRouter>
    );
    expect(screen.getByText(/contacto@rotsu.com/i)).toBeInTheDocument();
  });

  it('muestra el año actual en el copyright', () => {
    render(
      <MemoryRouter>
        <Footer />
      </MemoryRouter>
    );
    const year = new Date().getFullYear();
    expect(screen.getByText(new RegExp(year.toString()))).toBeInTheDocument();
  });

  it('muestra enlaces rápidos hacia las páginas', () => {
    render(
      <MemoryRouter>
        <Footer />
      </MemoryRouter>
    );
    expect(screen.getByRole('link', { name: 'Servicios' })).toHaveAttribute('href', '/servicios');
    expect(screen.getByRole('link', { name: 'Portafolio' })).toHaveAttribute('href', '/portafolio');
  });
});
