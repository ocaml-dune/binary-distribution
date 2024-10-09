const figma_color = {
  primary_light: "#C24F1E",
  primary_dark: "#D54000",
  secondary: "#111827",
  tertiary: "#3882B7",
  code_background: "#2B2A2A",
  installation_background: "#FAF8F3",
  paragraph: "#555659",
  curl_icon: "#364150",
  faq_background: "#D0D0D0",
};

/** @type {import('tailwindcss').Config} */
export default {
  content: ["**/*.mlx"],
  theme: {
    extend: {
      colors: {
        primary: {
          light: figma_color.primary_light,
          dark: figma_color.primary_dark,
        },

        secondary: figma_color.secondary,
        tertiary: figma_color.tertiary,
        section: {
          manual: figma_color.installation_background,
          code: figma_color.code_background,
          faq: {
            background: figma_color.faq_background,
          },
        },
        copy: figma_color.curl_icon,
        block: {
          p: figma_color.paragraph,
        },
      },
      maxWidth: {
        sixty: "60%",
      },
    },
    borderWidth: {
      DEFAULT: "1px",
    },
  },
};
