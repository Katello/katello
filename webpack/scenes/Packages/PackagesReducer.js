import Immutable from 'seamless-immutable';
import {
  PACKAGES_REQUEST,
  PACKAGES_SUCCESS,
  PACKAGES_FAILURE,
} from './PackagesConstants';

const initialState = Immutable({
  loading: false,
  packages: [],
});

export default (state = initialState, action) => {
  switch (action.type) {
    case PACKAGES_REQUEST: {
      return state.set('loading', true);
    }

    case PACKAGES_SUCCESS: {
      const packages = action.response.results;

      return state.merge({
        packages,
        loading: false,
      });
    }

    case PACKAGES_FAILURE: {
      return state.merge({
        error: action.error,
        loading: false,
      });
    }

    default:
      return state;
  }
}
