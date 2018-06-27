import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import configureMockStore from 'redux-mock-store';
import {
  manifestHistorySuccessResponse,
  manifestHistorySuccessActions,
  manifestHistoryFailureActions,
  taskSuccessResponse,
  uploadManifestSuccessActions,
  uploadManifestFailureActions,
  refreshManifestSuccessActions,
  refreshManifestFailureActions,
  deleteManifestSuccessActions,
  deleteManifestFailureActions,
} from './manifest.fixtures';
import { loadManifestHistory, uploadManifest, refreshManifest, deleteManifest } from '../ManifestActions';
import { mock as mockApi, mockErrorRequest } from '../../../../mockRequest';

const mockStore = configureMockStore([thunk]);
const store = mockStore({ manifest: Immutable({}) });

beforeEach(() => {
  store.clearActions();
  mockApi.reset();
});

let originalTimeout;

beforeEach(() => {
  originalTimeout = jasmine.DEFAULT_TIMEOUT_INTERVAL;
  jasmine.DEFAULT_TIMEOUT_INTERVAL = 10000;
});

afterEach(() => {
  jasmine.DEFAULT_TIMEOUT_INTERVAL = originalTimeout;
});

describe('manifest actions', () => {
  describe('creates GET_MANIFEST_HISTORY_REQUEST', () => {
    const url = '/katello/api/v2/organizations/1/subscriptions/manifest_history';

    it('and then fails with 422', () => {
      mockErrorRequest({
        url,
        status: 422,
      });

      return store.dispatch(loadManifestHistory())
        .then(() => expect(store.getActions()).toEqual(manifestHistoryFailureActions));
    });

    it('and ends with success', () => {
      mockApi.onGet(url).reply(200, manifestHistorySuccessResponse);

      return store.dispatch(loadManifestHistory())
        .then(() => expect(store.getActions()).toEqual(manifestHistorySuccessActions));
    });
  });

  describe('creates UPLOAD_MANIFEST_REQUEST', () => {
    const url = '/katello/api/v2/organizations/1/subscriptions/upload';

    it('and then fails with 422', () => {
      mockErrorRequest({
        url,
        status: 422,
        method: 'POST',
      });

      return store.dispatch(uploadManifest())
        .then(() => expect(store.getActions()).toEqual(uploadManifestFailureActions));
    });

    it('and ends with success', () => {
      mockApi.onPost(url).reply(200, taskSuccessResponse);

      return store.dispatch(uploadManifest())
        .then(() => expect(store.getActions()).toEqual(uploadManifestSuccessActions));
    });
  });

  describe('creates REFRESH_MANIFEST_REQUEST', () => {
    const url = '/katello/api/v2/organizations/1/subscriptions/refresh_manifest';

    it('and then fails with 422', () => {
      mockErrorRequest({
        url,
        status: 422,
        method: 'PUT',
      });

      return store.dispatch(refreshManifest())
        .then(() => expect(store.getActions()).toEqual(refreshManifestFailureActions));
    });

    it('and ends with success', () => {
      mockApi.onPut(url).reply(200, taskSuccessResponse);

      return store.dispatch(refreshManifest())
        .then(() => expect(store.getActions()).toEqual(refreshManifestSuccessActions));
    });
  });

  describe('creates DELETE_MANIFEST_REQUEST', () => {
    const url = '/katello/api/v2/organizations/1/subscriptions/delete_manifest';

    it('and then fails with 422', () => {
      mockErrorRequest({
        url,
        status: 422,
        method: 'POST',
      });

      return store.dispatch(deleteManifest())
        .then(() => expect(store.getActions()).toEqual(deleteManifestFailureActions));
    });

    it('and ends with success', () => {
      mockApi.onPost(url).reply(200, taskSuccessResponse);

      return store.dispatch(deleteManifest())
        .then(() => expect(store.getActions()).toEqual(deleteManifestSuccessActions));
    });
  });
});
