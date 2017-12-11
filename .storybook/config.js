import { configure } from '@storybook/react';

global.__ = str => str;

function loadStories() {
  require('../webpack/stories');
}

configure(loadStories, module);
