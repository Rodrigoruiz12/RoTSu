import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { ServicioCard } from './ServicioCard';

describe('ServicioCard', () => {
  it('muestra título y descripción', () => {
    render(
      <ServicioCard
        title="Desarrollo Web"
        description="Sitios modernos y rápidos"
        icon={<span data-testid="icon">icono</span>}
      />
    );
    expect(screen.getByRole('heading', { level: 3 })).toHaveTextContent('Desarrollo Web');
    expect(screen.getByText(/Sitios modernos/i)).toBeInTheDocument();
  });

  it('renderiza el icono recibido por props', () => {
    render(
      <ServicioCard
        title="X"
        description="Y"
        icon={<span data-testid="icon">icono</span>}
      />
    );
    expect(screen.getByTestId('icon')).toBeInTheDocument();
  });
});
