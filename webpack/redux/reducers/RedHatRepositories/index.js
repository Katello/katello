import { combineReducers } from '@theforeman/vendor/redux';
import enabled from './enabled';
import sets from './sets';
import repositorySetRepositories from './repositorySetRepositories';

export default combineReducers({
  repositorySetRepositories,
  sets,
  enabled,
});
