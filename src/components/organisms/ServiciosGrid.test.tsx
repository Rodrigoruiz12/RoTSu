import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { ServiciosGrid } from './ServiciosGrid';

describe('ServiciosGrid', () => {
  it('muestra el encabezado de sección', () => {
    render(<ServiciosGrid />);
    expect(screen.getByRole('heading', { level: 2 })).toHaveTextContent('Nuestros Servicios');
  });

  it('renderiza las 6 tarjetas de servicios', () => {
    render(<ServiciosGrid />);
    expect(screen.getAllByRole('heading', { level: 3 }).length).toBe(6);
  });

  it('incluye los servicios clave en el listado', () => {
    render(<ServiciosGrid />);
    expect(screen.getByText('Páginas Web Modernas')).toBeInTheDocument();
    expect(screen.getByText('Infraestructura y DevOps')).toBeInTheDocument();
  });
});
