import { GET_SETTING_SUCCESS } from 'foremanReact/components/Settings/SettingsConstants';
import { CONTENT_DISCONNECTED } from './SettingsConstants';

export default (state, action) => {
  switch (action.type) {
  case GET_SETTING_SUCCESS: {
    const { name, value } = action.response;
    switch (name) {
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
