/* eslint import/no-unresolved: [2, { ignore: [foremanReact/*] }] */
/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable import/extensions */
/* eslint-disable import/no-unresolved */

import componentRegistry from 'foremanReact/components/componentRegistry';
import SCAContainer from './scenes/Subscriptions/Manifest/SCAContainer';
import Application from './containers/Application/index';
import './redux';
// Not currently mocking anything
// import './services/api/setupMocks';

componentRegistry.register({
  name: 'katello',
  type: Application,
});

componentRegistry.register({
  name: 'SCAContainer',
  type: SCAContainer,
  store: true,
  data: true,
});
