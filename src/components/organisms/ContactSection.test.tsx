import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ContactSection } from './ContactSection';

describe('ContactSection', () => {
  it('muestra el encabezado "Contáctanos"', () => {
    render(<ContactSection />);
    expect(screen.getByRole('heading', { level: 2 })).toHaveTextContent('Contáctanos');
  });

  it('renderiza el formulario con los campos esperados', () => {
    render(<ContactSection />);
    expect(screen.getByLabelText(/nombre/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/correo electrónico/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/asunto/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/mensaje/i)).toBeInTheDocument();
  });

  it('permite escribir en los campos del formulario', async () => {
    render(<ContactSection />);
    const nombre = screen.getByLabelText(/nombre/i);
    await userEvent.type(nombre, 'Juan Pérez');
    expect(nombre).toHaveValue('Juan Pérez');
  });

  it('muestra el botón "Enviar Mensaje"', () => {
    render(<ContactSection />);
    expect(screen.getByRole('button', { name: /enviar mensaje/i })).toBeInTheDocument();
  });
});
