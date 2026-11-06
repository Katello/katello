const path = require('path');

module.exports = {
  presets: [
    require.resolve(path.resolve(__dirname, '../foreman/webpack/babel')),
  ],
};
