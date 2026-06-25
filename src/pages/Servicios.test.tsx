import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Servicios } from './Servicios';

describe('Página Servicios', () => {
  it('muestra el listado de servicios', () => {
    render(<Servicios />);
    expect(screen.getByText('Páginas Web Modernas')).toBeInTheDocument();
    expect(screen.getAllByRole('heading', { level: 3 }).length).toBe(6);
  });
});
