import Immutable from 'seamless-immutable';

import {
  MANIFEST_HISTORY_REQUEST,
  MANIFEST_HISTORY_SUCCESS,
  MANIFEST_HISTORY_FAILURE,
  UPLOAD_MANIFEST_SUCCESS,
  DELETE_MANIFEST_SUCCESS,
  DELETE_TASKED_ORG,
} from './ManifestConstants';

const initialState = Immutable({ loading: true, results: [] });

export default (state = initialState, action) => {
  switch (action.type) {
    case MANIFEST_HISTORY_REQUEST:
      return state.set('loading', true);

    case MANIFEST_HISTORY_SUCCESS: {
      const results = action.response;

      return state.merge({
        results,
        loading: false,
      });
    }

    case MANIFEST_HISTORY_FAILURE:
      return state.merge({
        error: action.payload.message,
        loading: false,
      });

    case UPLOAD_MANIFEST_SUCCESS:
      return state
        .set('taskDetails', action.response)
        .set('activeTaskOrg', action.activeTaskOrg)
        .set('activeOrgName', action.activeOrgName);

    case DELETE_MANIFEST_SUCCESS:
      return state
        .set('taskDetails', action.response)
        .set('activeTaskOrg', action.activeTaskOrg)
        .set('activeOrgName', action.activeOrgName);

    case DELETE_TASKED_ORG:
      return state
        .set('activeTaskOrg', null);

    default:
      return state;
  }
};
