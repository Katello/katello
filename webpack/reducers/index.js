/* eslint import/no-unresolved: [2, { ignore: [foremanReact/*] }] */
/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable import/extensions */
import { combineReducers } from 'redux';
import redHatRepositories from './RedHatRepositories';

const rootReducer = combineReducers({
  redHatRepositories,
});

export default rootReducer;

// Waiting for foreman to enable adding registering reducers
// import { registerReducer } from 'foremanReact/common/MountingService';
// registerReducer('katello_reducers', rootReducer);
