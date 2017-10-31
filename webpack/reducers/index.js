import { combineReducers } from 'redux';
import redHatRepositories from './RedHatRepositories';
import redHatRepositorySets from './RedHatRepositorySets';

const rootReducer = combineReducers({
  redHatRepositories,
  redHatRepositorySets
});

export default rootReducer;
