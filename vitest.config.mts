// Pruebas del proyecto (guía §10: tests/unit, tests/integration, tests/e2e).
//   npm run test:unit         → sin bases de datos (repositorios falsos)
//   npm run test:integration  → contra las bases de Docker (npm run db:up antes)
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    env: { NODE_ENV: 'test' },
    projects: [
      { test: { name: 'unit', include: ['tests/unit/**/*.test.ts'] } },
      {
        test: {
          name: 'integration',
          include: ['tests/integration/**/*.test.ts'],
          testTimeout: 20_000,
          fileParallelism: false,
        },
      },
    ],
  },
});
