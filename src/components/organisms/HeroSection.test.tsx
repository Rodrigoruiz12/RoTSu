import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { HeroSection } from './HeroSection';

describe('HeroSection', () => {
  it('muestra el título principal con texto clave', () => {
    render(
      <MemoryRouter>
        <HeroSection />
      </MemoryRouter>
    );
    expect(screen.getByRole('heading', { level: 1 })).toBeInTheDocument();
    expect(screen.getByText(/Transformamos tus ideas/i)).toBeInTheDocument();
  });

  it('muestra botones de CTA hacia /contacto y /portafolio', () => {
    render(
      <MemoryRouter>
        <HeroSection />
      </MemoryRouter>
    );
    expect(screen.getByRole('link', { name: /iniciar un proyecto/i })).toHaveAttribute('href', '/contacto');
    expect(screen.getByRole('link', { name: /ver portafolio/i })).toHaveAttribute('href', '/portafolio');
  });
});
