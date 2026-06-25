import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { SobreNosotros } from './SobreNosotros';

describe('Página SobreNosotros', () => {
  it('muestra el encabezado de sección', () => {
    render(<SobreNosotros />);
    expect(screen.getByRole('heading', { level: 2 })).toHaveTextContent('Sobre Nosotros');
  });
});
