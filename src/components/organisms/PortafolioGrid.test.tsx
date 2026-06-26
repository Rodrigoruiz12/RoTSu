import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { PortafolioGrid } from './PortafolioGrid';

describe('PortafolioGrid', () => {
  it('muestra el encabezado "Casos de Éxito"', () => {
    render(<PortafolioGrid />);
    expect(screen.getByRole('heading', { level: 2 })).toHaveTextContent('Casos de Éxito');
  });

  it('renderiza las 4 tarjetas de proyectos', () => {
    render(<PortafolioGrid />);
    expect(screen.getAllByRole('heading', { level: 3 }).length).toBe(4);
  });

  it('incluye proyectos esperados', () => {
    render(<PortafolioGrid />);
    expect(screen.getByText('Plataforma E-commerce Muebles')).toBeInTheDocument();
    expect(screen.getByText('Sistema ERP Textil')).toBeInTheDocument();
  });
});
