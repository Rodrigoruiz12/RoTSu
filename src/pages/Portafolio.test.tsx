import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Portafolio } from './Portafolio';

describe('Página Portafolio', () => {
  it('muestra los proyectos del portafolio', () => {
    render(<Portafolio />);
    expect(screen.getByText('Plataforma E-commerce Muebles')).toBeInTheDocument();
    expect(screen.getAllByRole('heading', { level: 3 }).length).toBe(4);
  });
});
