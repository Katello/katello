/* eslint import/no-unresolved: [2, { ignore: [foremanReact/*] }] */
/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable import/extensions */
import { combineReducers } from 'redux';
import { registerReducer } from 'foremanReact/common/MountingService';
import redHatRepositories from './RedHatRepositories';

const rootReducer = combineReducers({
  redHatRepositories,
});

registerReducer('katello', rootReducer);
