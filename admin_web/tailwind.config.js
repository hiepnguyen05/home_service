/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                "primary": "#19e620",
                "background-light": "#f6f8f6",
                "background-dark": "#112111",
                "surface-light": "#ffffff",
                "surface-dark": "#1a2e1a",
                "text-light": "#1f2937",
                "text-dark": "#e5e7eb",
                "text-secondary-light": "#6b7280",
                "text-secondary-dark": "#9ca3af"
            },
            fontFamily: {
                "display": ["Inter", "sans-serif"]
            },
        },
    },
    plugins: [],
}
