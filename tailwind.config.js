/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./app/**/*.{js,jsx}", "./components/**/*.{js,jsx}"],
  theme: {
    extend: {
      colors: {
        paper: "#F6F4EE",
        panel: "#FFFFFF",
        ink: "#20242B",
        inkMuted: "#767B85",
        hair: "#E5E1D6",
        blueprint: "#17293F",
        sage: "#8FB596",
        sageTag: "#5F8367",
        slateBlue: "#8CA3C4",
        slateTag: "#5E7CA3",
        amber: "#D6A24C",
        amberTag: "#A87C34",
      },
      fontFamily: {
        serif: ["Fraunces", "serif"],
        sans: ["Inter", "system-ui", "sans-serif"],
        mono: ["JetBrains Mono", "ui-monospace", "monospace"],
      },
    },
  },
  plugins: [],
};
