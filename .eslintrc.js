module.exports = {
  env: {
    browser: true,
    'jest/globals': true,
  },
  extends: ['airbnb', 'plugin:jest/recommended'],
  plugins: ['jest', 'react'],
  rules: {
    'react/jsx-filename-extension': 'off',
  },
};
