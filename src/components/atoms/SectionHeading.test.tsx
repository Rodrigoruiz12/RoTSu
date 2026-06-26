import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { SectionHeading } from './SectionHeading';

describe('SectionHeading', () => {
  it('muestra el título recibido', () => {
    render(<SectionHeading title="Nuestros servicios" />);
    expect(screen.getByRole('heading', { level: 2 })).toHaveTextContent('Nuestros servicios');
  });

  it('muestra el subtítulo cuando se proporciona', () => {
    render(<SectionHeading title="Título" subtitle="Subtítulo de prueba" />);
    expect(screen.getByText(/Subtítulo de prueba/i)).toBeInTheDocument();
  });

  it('no renderiza subtítulo cuando no se proporciona', () => {
    render(<SectionHeading title="Título" />);
    expect(screen.queryByText(/subtítulo/i)).not.toBeInTheDocument();
  });

  it('aplica alineación centrada por defecto', () => {
    render(<SectionHeading title="Centrado" />);
    expect(screen.getByRole('heading', { level: 2 }).parentElement).toHaveClass('text-center');
  });

  it('aplica alineación izquierda cuando centered=false', () => {
    render(<SectionHeading title="Izquierda" centered={false} />);
    expect(screen.getByRole('heading', { level: 2 }).parentElement).toHaveClass('text-left');
  });
});
