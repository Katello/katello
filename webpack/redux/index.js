/* eslint import/no-unresolved: [2, { ignore: [foremanReact/*] }] */
/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable import/extensions */
/* eslint-disable import/no-unresolved */

import { registerReducer } from 'foremanReact/common/MountingService';
import rootReducer from './reducers';

registerReducer('katello', rootReducer);
