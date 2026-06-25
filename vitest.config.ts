import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  plugins: [react(), tailwindcss()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test/setup.ts'],
    css: false,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov', 'json-summary', 'json'],
      reportsDirectory: './coverage',
      exclude: [
        'node_modules/',
        'dist/',
        'src/test/',
        'src/frontend.tsx',
        'src/App.test.tsx',
        'src/APITester.tsx',
        'test-lucide.ts',
        '**/*.d.ts',
        'vite.config.ts',
        'vitest.config.ts',
      ],
      thresholds: {
        lines: 70,
        functions: 70,
        branches: 60,
        statements: 70,
      },
    },
  },
});
