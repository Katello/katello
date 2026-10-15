const path = require('path');

module.exports = {
  presets: [
    require.resolve('@theforeman/builder/babel', {
      paths: [path.resolve(__dirname, '../foreman')],
    }),
  ],
};