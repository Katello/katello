const path = require('path');
const fs = require('fs');

const getForemanLocation = () => {
  const foremanLocations = ['./foreman', '../foreman', '../../foreman'];
  const notFound = 'Foreman directory cannot be found! This action requires Foreman to be present ' +
  'in either a parent, sibling, or child directory relative to the plugin.';
  const currentDir = process.cwd();
  let fullPath;

  foremanLocations.forEach((relativeForemanPath) => {
    const possibleForemanPath = path.join(currentDir, relativeForemanPath);
    if (fs.existsSync(possibleForemanPath)) fullPath = possibleForemanPath;
  });

  if (!fullPath) throw new Error(notFound);
  return fullPath;
};

// Get a subdirectory within Foreman
const getForemanRelativePath = (relativeForemanPath) => {
  const foremanLocation = getForemanLocation();
  const notFound = `Could not find ${relativeForemanPath} in ${foremanLocation}`;
  const foremanRelativePath = path.join(foremanLocation, relativeForemanPath);
  if (!fs.existsSync(foremanRelativePath)) throw new Error(notFound);
  return foremanRelativePath;
};

module.exports = { getForemanLocation, getForemanRelativePath };
