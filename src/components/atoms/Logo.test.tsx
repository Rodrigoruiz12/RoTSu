import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Logo } from './Logo';

describe('Logo', () => {
  it('muestra el texto RoTSu', () => {
    render(<Logo />);
    expect(screen.getByText(/RoTSu/i)).toBeInTheDocument();
  });

  it('aplica la clase personalizada pasada por props', () => {
    const { container } = render(<Logo className="mi-clase" />);
    expect(container.firstChild).toHaveClass('mi-clase');
  });
});
