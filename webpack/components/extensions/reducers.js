import { combineReducers } from 'redux';
import { reducers as systemStatuses } from './about';

export default combineReducers({
  ...systemStatuses,
});
