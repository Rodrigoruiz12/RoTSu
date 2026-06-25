import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { AboutUsSection } from './AboutUsSection';

describe('AboutUsSection', () => {
  it('muestra el encabezado "Sobre Nosotros"', () => {
    render(<AboutUsSection />);
    expect(screen.getByRole('heading', { level: 2 })).toHaveTextContent('Sobre Nosotros');
  });

  it('muestra la misión de la empresa', () => {
    render(<AboutUsSection />);
    expect(screen.getByRole('heading', { level: 4, name: /nuestra misión/i })).toBeInTheDocument();
  });

  it('muestra las métricas (+50 proyectos y 100% compromiso)', () => {
    render(<AboutUsSection />);
    expect(screen.getByText('+50')).toBeInTheDocument();
    expect(screen.getByText('100%')).toBeInTheDocument();
  });
});
