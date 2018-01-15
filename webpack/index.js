/* eslint import/no-unresolved: [2, { ignore: [foremanReact/*] }] */
/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable import/extensions */
/* eslint-disable import/no-unresolved */

import componentRegistry from 'foremanReact/components/componentRegistry';
import { mount } from 'foremanReact/common/MountingService';
import ExperimentalUi from './containers/Application/index';
import './redux';
// Not currently mocking anything
// import './services/api/setupMocks';

componentRegistry.register({
  name: 'xui_katello',
  type: ExperimentalUi,
});

mount('xui_katello', '#reactRoot');
