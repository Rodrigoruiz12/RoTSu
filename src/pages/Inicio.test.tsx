import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { Inicio } from './Inicio';

describe('Página Inicio', () => {
  it('renderiza HeroSection con el título principal', () => {
    render(
      <MemoryRouter>
        <Inicio />
      </MemoryRouter>
    );
    expect(screen.getByRole('heading', { level: 1 })).toBeInTheDocument();
  });
});
