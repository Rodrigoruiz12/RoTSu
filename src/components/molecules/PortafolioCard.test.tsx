import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { PortafolioCard } from './PortafolioCard';

describe('PortafolioCard', () => {
  it('muestra el título y categoría recibidos', () => {
    render(<PortafolioCard title="Proyecto Alpha" category="Web" />);
    expect(screen.getByText('Proyecto Alpha')).toBeInTheDocument();
    expect(screen.getByText('Web')).toBeInTheDocument();
  });

  it('renderiza la imagen cuando se proporciona imageUrl', () => {
    render(<PortafolioCard title="Con imagen" category="Diseño" imageUrl="https://example.com/x.png" />);
    const img = screen.getByRole('img');
    expect(img).toHaveAttribute('src', 'https://example.com/x.png');
    expect(img).toHaveAttribute('alt', 'Con imagen');
  });

  it('no renderiza img cuando no se proporciona imageUrl', () => {
    render(<PortafolioCard title="Sin imagen" category="Web" />);
    expect(screen.queryByRole('img')).not.toBeInTheDocument();
  });
});
