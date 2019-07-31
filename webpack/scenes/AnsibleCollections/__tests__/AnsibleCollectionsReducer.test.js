import {
  ANSIBLE_COLLECTIONS_REQUEST,
  ANSIBLE_COLLECTIONS_SUCCESS,
  ANSIBLE_COLLECTIONS_ERROR,
} from '../AnsibleCollectionsConstants';
import {
  initialState,
  loadingState,
  successState,
  results,
} from './AnsibleCollections.fixtures';
import reducer from '../AnsibleCollectionsReducer';

describe('ansible collections reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should keep loading state on ANSIBLE_COLLECTIONS_REQUEST', () => {
    expect(reducer(initialState, {
      type: ANSIBLE_COLLECTIONS_REQUEST,
    })).toEqual(loadingState);
  });

  it('load ansible collections on ANSIBLE_COLLECTIONS_SUCCESS', () => {
    expect(reducer(initialState, {
      type: ANSIBLE_COLLECTIONS_SUCCESS,
      response: {
        ...initialState,
        results,
      },
    })).toEqual(successState);
  });

  it('load error on ANSIBLE_COLLECTIONS_ERROR', () => {
    const error = 'nothing worked';
    expect(reducer(initialState, {
      type: ANSIBLE_COLLECTIONS_ERROR,
      error,
    })).toEqual({
      ...initialState,
      loading: false,
      error,
    });
  });
});
