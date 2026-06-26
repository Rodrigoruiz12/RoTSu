import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Contacto } from './Contacto';

describe('Página Contacto', () => {
  it('muestra el formulario de contacto', () => {
    render(<Contacto />);
    expect(screen.getByLabelText(/nombre/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/correo electrónico/i)).toBeInTheDocument();
  });

  it('permite rellenar el asunto', async () => {
    render(<Contacto />);
    const asunto = screen.getByLabelText(/asunto/i);
    await userEvent.type(asunto, 'Cotización web');
    expect(asunto).toHaveValue('Cotización web');
  });
});
