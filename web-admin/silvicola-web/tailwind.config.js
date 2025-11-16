/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9f4',
          100: '#dcf2e4',
          200: '#bce5cd',
          300: '#8dd0ab',
          400: '#5ab282',
          500: '#2e7d32',
          600: '#256d2b',
          700: '#1e5723',
          800: '#1a461e',
          900: '#163919',
        },
        secondary: {
          50: '#faf7f5',
          100: '#f3ede9',
          200: '#e5d8d0',
          300: '#d4bcb0',
          400: '#be9c91',
          500: '#8d6e63',
          600: '#7d5f54',
          700: '#6b4f45',
          800: '#5f4339',
          900: '#523930',
        },
      },
    },
  },
  plugins: [],
}
