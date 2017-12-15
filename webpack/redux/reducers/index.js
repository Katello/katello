/* eslint import/no-unresolved: [2, { ignore: [foremanReact/*] }] */
/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable import/extensions */
/* eslint-disable import/no-unresolved */

import { combineReducers } from 'redux';
import { registerReducer } from 'foremanReact/common/MountingService';
import redHatRepositories from './RedHatRepositories';
import general from './General';

const rootReducer = combineReducers({
  general,
  redHatRepositories,
});

registerReducer('katello', rootReducer);
