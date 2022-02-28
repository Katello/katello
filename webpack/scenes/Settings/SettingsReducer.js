import Immutable from 'seamless-immutable';
import { GET_SETTING_SUCCESS } from 'foremanReact/components/Settings/SettingsConstants';
import {
  AUTOSEARCH_DELAY,
  AUTOSEARCH_WHILE_TYPING,
  CONTENT_DISCONNECTED,
} from './SettingsConstants';

export const initialSettingsState = Immutable({
  autoSearchEnabled: true,
  autoSearchDelay: 500,
});

export default (state = initialSettingsState, action) => {
  switch (action.type) {
  case GET_SETTING_SUCCESS: {
    const { name, value } = action.response;
    switch (name) {
    case AUTOSEARCH_DELAY:
      return state.set('autoSearchDelay', value);
    case AUTOSEARCH_WHILE_TYPING:
      return state.set('autoSearchEnabled', value);
    case CONTENT_DISCONNECTED:
      return state.set('disconnected', value);
    default:
      return state;
    }
  }

  default:
    return state;
  }
};
