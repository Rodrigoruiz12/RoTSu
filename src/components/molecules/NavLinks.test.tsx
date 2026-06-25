import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { NavLinks } from './NavLinks';

describe('NavLinks', () => {
  it('renderiza los 5 enlaces de navegación', () => {
    render(
      <MemoryRouter>
        <NavLinks />
      </MemoryRouter>
    );
    ['Inicio', 'Servicios', 'Sobre nosotros', 'Portafolio', 'Contacto'].forEach((name) => {
      expect(screen.getByRole('link', { name })).toBeInTheDocument();
    });
  });

  it('invoca onClick al hacer click en un enlace', async () => {
    const onClick = vi.fn();
    render(
      <MemoryRouter>
        <NavLinks onClick={onClick} />
      </MemoryRouter>
    );
    await userEvent.click(screen.getByRole('link', { name: 'Inicio' }));
    expect(onClick).toHaveBeenCalledOnce();
  });

  it('aplica la clase personalizada pasada por props', () => {
    const { container } = render(
      <MemoryRouter>
        <NavLinks className="mi-clase-nav" />
      </MemoryRouter>
    );
    expect(container.querySelector('ul')).toHaveClass('mi-clase-nav');
  });
});
