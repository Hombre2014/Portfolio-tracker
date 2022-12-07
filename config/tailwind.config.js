const defaultTheme = require('tailwindcss/defaultTheme');

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        dollar: {
          light: '#add197',
          DEFAULT: '#85bb65',
          dark: '#68a047',
          saturated: '#82c65a',
          inverted: '#7a449a',
          grayscale: '#909090',
          complement: '#6847A0', // used to be #923ae6
          split_blue: '#001E57', // used to be #216dff
          triad_red: '#ff214b',
          triad_blue: '#00571E', // used to be #21c2ff, then #0F1D38, #1D3159, #4C0094
          square_red: '#f95427',
          darker: '#68a047',
          square_blue: '#21daff',
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
