import { combineReducers } from 'redux';
import enabled from './enabled';
import sets from './sets';

export default combineReducers({
  sets,
  enabled,
});
