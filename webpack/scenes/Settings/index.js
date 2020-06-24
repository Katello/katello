import { combineReducers } from 'redux';
import tables from './Tables/TableReducer';
import settings from './SettingsReducer';

export default combineReducers({ tables, settings });
