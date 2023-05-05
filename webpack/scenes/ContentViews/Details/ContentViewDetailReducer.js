import Immutable from 'seamless-immutable';
import {
  UPDATE_CONTENT_VIEW,
  UPDATE_CONTENT_VIEW_FAILURE,
  UPDATE_CONTENT_VIEW_SUCCESS,
  CONTENT_VIEW_NEEDS_PUBLISH,
  CONTENT_VIEW_NEEDS_PUBLISH_RESET,
} from '../ContentViewsConstants';

const initialState = Immutable({
  updating: false,
});

export default (state = initialState, action) => {
  switch (action.type) {
  case UPDATE_CONTENT_VIEW:
    return state.set('updating', true);
  case UPDATE_CONTENT_VIEW_SUCCESS:
    return state.merge({ updating: false });
  case UPDATE_CONTENT_VIEW_FAILURE:
    return state.set('updating', false);
  case CONTENT_VIEW_NEEDS_PUBLISH:
    return state.set('needsPublish', true);
  case CONTENT_VIEW_NEEDS_PUBLISH_RESET:
    return state.set('needsPublish', false);
  default:
    return state;
  }
};
