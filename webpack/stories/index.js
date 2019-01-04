import { configure } from '@storybook/react';

require('@theforeman/vendor/node_modules/patternfly/dist/css/patternfly.min.css');
require('@theforeman/vendor/node_modules/patternfly/dist/css/patternfly-additions.min.css');

const req = require.context('../', true, /.stories.js$/);

function loadStories() {
  req.keys().forEach(filename => req(filename));
}

configure(loadStories, module);
