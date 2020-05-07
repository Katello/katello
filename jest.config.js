const { getForemanLocation, getForemanRelativePath } = require('./webpack/test-utils/findForeman.js')
const foremanReactRelative = 'webpack/assets/javascripts/react_app';
const foremanFull = getForemanLocation();
const foremanReactFull = getForemanRelativePath(foremanReactRelative);

// Jest configuration
module.exports = {
  collectCoverage: true,
  collectCoverageFrom: [
    'webpack/**/*.js',
    '!webpack/**/bundle*',
  ],
  coverageReporters: [
    'lcov',
  ],
  testURL: 'http://localhost/',
  setupFiles: [
    './webpack/test_setup.js',
  ],
  setupFilesAfterEnv: [
    './webpack/global_test_setup.js',
    '@testing-library/jest-dom'
  ],
  testPathIgnorePatterns: [
    '/node_modules/',
    '<rootDir>/foreman/',
    '<rootDir>/.+fixtures.+',
    '<rootDir>/engines',
  ],
  moduleDirectories: [
    `${foremanFull}/node_modules`,
    `${foremanFull}/node_modules/@theforeman/vendor-core/node_modules`,
    'node_modules',
    'webpack/test-utils',
  ],
  modulePathIgnorePatterns: [
    '<rootDir>/foreman/',
  ],
  moduleNameMapper: {
    '^.+\\.(css|scss)$': 'identity-obj-proxy',
    '^foremanReact(.*)$': `${foremanReactFull}/$1`,
  },
};

