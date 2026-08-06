const path = require('path');
const tfmConfig = require('@theforeman/test/src/pluginConfig');
const { foremanLocation, foremanRelativePath } = require('@theforeman/find-foreman');

const pluginRoot = __dirname;
const foremanReactRelative = 'webpack/assets/javascripts/react_app';
const foremanFull = foremanLocation();
const foremanReactFull = foremanRelativePath(foremanReactRelative);

// pluginConfig uses process.cwd(), which is Foreman when run via test:plugins
tfmConfig.rootDir = pluginRoot;
tfmConfig.roots = [`${pluginRoot}/webpack/`];
tfmConfig.coverageDirectory = `${pluginRoot}/coverage`;
tfmConfig.setupFiles = [
  require.resolve('raf/polyfill', { paths: [pluginRoot] }),
  require.resolve('jest-prop-type-error', { paths: [pluginRoot] }),
  require.resolve('@theforeman/test/src/test_setup.js', { paths: [pluginRoot] }),
  `${pluginRoot}/webpack/test_setup.js`,
];

tfmConfig.logHeapUsage = true;
tfmConfig.maxWorkers = 2;

tfmConfig.setupFilesAfterEnv = [
  './webpack/global_test_setup.js',
  '@testing-library/jest-dom',
];

tfmConfig.testPathIgnorePatterns = [
  '/node_modules/',
  '<rootDir>/foreman/',
  '<rootDir>/.+fixtures.+',
  '<rootDir>/engines',
  '<rootDir>/vendor/',
  '/gems/',
  '<rootDir>/.vendor/',
  '.+fixtures.+',
  'foreman/webpack',
];

tfmConfig.modulePathIgnorePatterns = ['<rootDir>/foreman/'];

tfmConfig.moduleNameMapper['^foremanReact(.*)$'] = `${foremanReactFull}/$1`;
tfmConfig.moduleNameMapper['^foremanJSTestSetup$'] =
  foremanRelativePath('webpack/core_test_setup.js');

tfmConfig.resolver = null;
tfmConfig.moduleDirectories = [
  `${foremanFull}/node_modules`,
  `${foremanFull}/node_modules/@theforeman/vendor-core/node_modules`,
  'node_modules',
  'webpack/test-utils',
];

// Use Foreman's babel-jest when katello's @babel/core is too old for @theforeman/test
tfmConfig.transform['^.+\\.js$'] = [
  require.resolve('babel-jest', { paths: [foremanFull] }),
  { configFile: path.join(foremanFull, 'babel.config.js') },
];

module.exports = tfmConfig;
