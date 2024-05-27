const { foremanLocation, foremanRelativePath } = require('@theforeman/find-foreman')
const foremanReactRelative = 'webpack/assets/javascripts/react_app';
const foremanFull = foremanLocation();
const foremanReactFull = foremanRelativePath(foremanReactRelative);

// Jest configuration
module.exports = {
  logHeapUsage: true,
  maxWorkers: 2,
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
    '<rootDir>/vendor/',
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

