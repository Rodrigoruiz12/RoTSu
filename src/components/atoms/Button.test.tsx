import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Button } from './Button';

describe('Button', () => {
  it('renderiza el texto proporcionado', () => {
    render(<Button>Click aquí</Button>);
    expect(screen.getByRole('button', { name: /click aquí/i })).toBeInTheDocument();
  });

  it('invoca onClick al hacer click', async () => {
    const onClick = vi.fn();
    render(<Button onClick={onClick}>Aceptar</Button>);
    await userEvent.click(screen.getByRole('button'));
    expect(onClick).toHaveBeenCalledOnce();
  });

  it('aplica la variante primary por defecto', () => {
    render(<Button>Default</Button>);
    const btn = screen.getByRole('button');
    expect(btn.className).toMatch(/bg-emerald-500/);
  });

  it('aplica la variante outline cuando se indica', () => {
    render(<Button variant="outline">Outline</Button>);
    expect(screen.getByRole('button').className).toMatch(/border-emerald-500/);
  });

  it('aplica clase fullWidth cuando fullWidth=true', () => {
    render(<Button fullWidth>Ancho total</Button>);
    expect(screen.getByRole('button').className).toMatch(/w-full/);
  });

  it('pasa atributos HTML adicionales (disabled, type)', () => {
    render(<Button disabled type="submit">Enviar</Button>);
    const btn = screen.getByRole('button');
    expect(btn).toBeDisabled();
    expect(btn).toHaveAttribute('type', 'submit');
  });
});
