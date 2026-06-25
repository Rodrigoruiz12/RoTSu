import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { MainLayout } from './MainLayout';

describe('MainLayout', () => {
  it('renderiza Navbar, Footer y el contenido hijo', () => {
    render(
      <MemoryRouter>
        <MainLayout>
          <div data-testid="hijo">Contenido de prueba</div>
        </MainLayout>
      </MemoryRouter>
    );
    expect(screen.getByTestId('hijo')).toBeInTheDocument();
    expect(screen.getAllByText(/RoTSu/i).length).toBeGreaterThan(0);
  });
});
