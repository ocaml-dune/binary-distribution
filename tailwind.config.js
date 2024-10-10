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
  gradient_start: "#0B1228",
  gradient_end: "#0F254F",
  information_background: "#F28B03",
};

/** @type {import('tailwindcss').Config} */
export default {
  content: ["**/*.mlx"],
  theme: {
    screens: {
      sm: "40em",
      md: "48em",
      lg: "64em",
    },
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
        gradient: {
          start: figma_color.gradient_start,
          end: figma_color.gradient_end,
        },
        warning: figma_color.information_background,
      },
      maxWidth: {
        banner: "890px",
        lg: "1280px",
      },
      width: {
        lg: "1280px",
      },
    },
    borderWidth: {
      DEFAULT: "1px",
    },
  },
};
