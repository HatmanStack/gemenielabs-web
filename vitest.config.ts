import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: [
      'tests/**/*.test.{js,ts}',
      'backend/**/*.test.{js,ts}',
    ],
    exclude: [
      '**/node_modules/**',
      'frontend/**',
      '**/.svelte-kit/**',
      '**/.aws-sam/**',
    ],
    testTimeout: 10000,
  },
});
