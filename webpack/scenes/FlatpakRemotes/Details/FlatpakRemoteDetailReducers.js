import Immutable from 'seamless-immutable';
import {
  UPDATE_FLATPAK_REMOTE,
  UPDATE_FLATPAK_REMOTE_FAILURE,
  UPDATE_FLATPAK_REMOTE_SUCCESS,
} from '../FlatpakRemotesConstants';

const initialState = Immutable({
  updating: false,
});

export default (state = initialState, action) => {
  switch (action.type) {
  case UPDATE_FLATPAK_REMOTE:
    return state.set('updating', true);
  case UPDATE_FLATPAK_REMOTE_SUCCESS:
    return state.merge({ updating: false });
  case UPDATE_FLATPAK_REMOTE_FAILURE:
    return state.set('updating', false);
  default:
    return state;
  }
};
