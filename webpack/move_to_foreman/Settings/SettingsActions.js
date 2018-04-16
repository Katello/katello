import { foremanApi as api } from '../../services/api';

import {
  GET_SETTING_REQUEST,
  GET_SETTING_SUCCESS,
  GET_SETTING_FAILURE,
} from './SettingsConstants';

export const loadSetting = settingName => (dispatch) => {
  dispatch({ type: GET_SETTING_REQUEST });

  return api
    .get(`/settings/${settingName}`)
    .then(({ data }) => {
      dispatch({
        type: GET_SETTING_SUCCESS,
        response: data,
      });
    })
    .catch((result) => {
      dispatch({
        type: GET_SETTING_FAILURE,
        result,
      });
    });
};

export default loadSetting;
