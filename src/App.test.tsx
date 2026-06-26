import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { App } from './App';

describe('App', () => {
  it('renderiza la aplicación sin caer', () => {
    render(<App />);
    expect(document.body).toBeTruthy();
  });

  it('muestra la marca RoTSu en el navbar', () => {
    render(<App />);
    expect(screen.getAllByText(/RoTSu/i).length).toBeGreaterThan(0);
  });
});
