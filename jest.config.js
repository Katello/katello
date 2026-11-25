const path = require('path');

const pluginRoot = __dirname;
const foremanFull =
  process.env.FOREMAN_PATH || path.resolve(__dirname, '../foreman');

module.exports = {
  rootDir: pluginRoot,
  roots: [`${pluginRoot}/webpack/`],
  coverageDirectory: `${pluginRoot}/coverage`,
  setupFiles: [
    require.resolve('raf/polyfill', { paths: [foremanFull, pluginRoot] }),
    require.resolve('jest-prop-type-error', { paths: [foremanFull, pluginRoot] }),
    `${pluginRoot}/webpack/test_setup.js`,
  ],
  logHeapUsage: true,
  maxWorkers: 2,
  setupFilesAfterEnv: [
    './webpack/global_test_setup.js',
    require.resolve('@testing-library/jest-dom', { paths: [foremanFull] }),
  ],
  testPathIgnorePatterns: [
    '/node_modules/',
    '<rootDir>/foreman/',
    '<rootDir>/.+fixtures.+',
    '<rootDir>/engines',
    '<rootDir>/vendor/',
    '/gems/',
    '<rootDir>/.vendor/',
    '.+fixtures.+',
    'foreman/webpack',
  ],
  modulePathIgnorePatterns: ['<rootDir>/foreman/'],
  moduleDirectories: [
    `${foremanFull}/node_modules`,
    'node_modules',
    'webpack/test-utils',
  ],
  resolver: null,
};
