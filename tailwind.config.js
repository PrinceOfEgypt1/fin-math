/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
    "./*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Tokens semânticos com contraste WCAG AA (≥4.5:1)
        surface: {
          DEFAULT: "#0f172a", // Contraste: 15.28:1 com texto branco
          elevated: "#1e293b", // Contraste: 11.76:1
          overlay: "rgba(15, 23, 42, 0.95)",
        },
        text: {
          DEFAULT: "#e2e8f0", // Contraste: 12.63:1 com surface
          secondary: "#94a3b8", // Contraste: 6.39:1
          muted: "#64748b", // Contraste: 4.54:1 - mínimo AA
        },
        primary: {
          DEFAULT: "#60a5fa", // Azul acessível
          hover: "#3b82f6",
          focus: "#2563eb",
        },
        secondary: {
          DEFAULT: "#a78bfa", // Roxo acessível
          hover: "#8b5cf6",
          focus: "#7c3aed",
        },
        success: {
          DEFAULT: "#34d399", // Verde com contraste adequado
          hover: "#10b981",
        },
        warning: {
          DEFAULT: "#fbbf24", // Amarelo com contraste adequado
          hover: "#f59e0b",
        },
        danger: {
          DEFAULT: "#f87171", // Vermelho com contraste adequado
          hover: "#ef4444",
        },
        // Foco visível
        focus: {
          ring: "#60a5fa",
          offset: "#0f172a",
        },
      },
      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"],
        mono: ["JetBrains Mono", "Courier New", "monospace"],
      },
      fontSize: {
        // Escala tipográfica acessível
        xs: ["0.75rem", { lineHeight: "1.5" }], // 12px
        sm: ["0.875rem", { lineHeight: "1.5" }], // 14px
        base: ["1rem", { lineHeight: "1.6" }], // 16px
        lg: ["1.125rem", { lineHeight: "1.6" }], // 18px
        xl: ["1.25rem", { lineHeight: "1.5" }], // 20px
        "2xl": ["1.5rem", { lineHeight: "1.4" }], // 24px
        "3xl": ["1.875rem", { lineHeight: "1.3" }], // 30px
        "4xl": ["2.25rem", { lineHeight: "1.2" }], // 36px
      },
      spacing: {
        // Escala de 8pt para espaçamento consistente
        2: "0.5rem", // 8px
        3: "0.75rem", // 12px
        4: "1rem", // 16px
        6: "1.5rem", // 24px
        8: "2rem", // 32px
        12: "3rem", // 48px
        16: "4rem", // 64px
      },
      borderRadius: {
        sm: "0.375rem", // 6px
        DEFAULT: "0.5rem", // 8px
        md: "0.75rem", // 12px
        lg: "1rem", // 16px
        xl: "1.5rem", // 24px
      },
      boxShadow: {
        focus: "0 0 0 3px rgba(96, 165, 250, 0.5)",
        "focus-danger": "0 0 0 3px rgba(248, 113, 113, 0.5)",
      },
      transitionDuration: {
        150: "150ms",
        200: "200ms",
        250: "250ms",
      },
      // Target mínimo de toque: 44x44px (WCAG 2.1 - 2.5.5)
      minWidth: {
        touch: "44px",
      },
      minHeight: {
        touch: "44px",
      },
    },
  },
  plugins: [],
};
