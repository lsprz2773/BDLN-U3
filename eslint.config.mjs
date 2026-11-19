// Lint de los paquetes de código del proyecto final (shared, backend, frontend, tests).
// El material de la actividad anterior (scripts/, presentacion/, entregables/) queda fuera.
import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import prettier from 'eslint-config-prettier';
import globals from 'globals';

export default tseslint.config(
  {
    ignores: [
      '**/node_modules/**',
      '**/dist/**',
      '**/coverage/**',
      'scripts/**',
      'presentacion/**',
      'entregables/**',
      'verificacion/**',
      'database/graph/runner/**',
    ],
  },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    languageOptions: { globals: { ...globals.node } },
    rules: {
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      'no-console': ['warn', { allow: ['warn', 'error'] }],
    },
  },
  {
    // La interfaz solo consume la API: nunca un driver de base de datos (guía §7.6).
    files: ['frontend/**/*.{ts,tsx}'],
    languageOptions: { globals: { ...globals.browser } },
    rules: {
      'no-restricted-imports': [
        'error',
        {
          paths: ['pg', 'mongodb', 'neo4j-driver'].map((name) => ({
            name,
            message:
              'El frontend no accede a las bases: usa la API del backend (convenciones §6.8).',
          })),
        },
      ],
    },
  },
  prettier,
);
