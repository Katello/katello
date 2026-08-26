import { API_OPERATIONS } from 'foremanReact/redux/API';
import {
  loadManifestHistory,
  uploadManifest,
  refreshManifest,
  deleteManifest,
} from '../ManifestActions';
import {
  UPLOAD_MANIFEST_KEY,
  REFRESH_MANIFEST_KEY,
  DELETE_MANIFEST_KEY,
  MANIFEST_HISTORY_KEY,
  UPLOAD_MANIFEST_REQUEST,
  UPLOAD_MANIFEST_SUCCESS,
  UPLOAD_MANIFEST_FAILURE,
  REFRESH_MANIFEST_REQUEST,
  REFRESH_MANIFEST_SUCCESS,
  REFRESH_MANIFEST_FAILURE,
  DELETE_MANIFEST_REQUEST,
  DELETE_MANIFEST_SUCCESS,
  DELETE_MANIFEST_FAILURE,
  MANIFEST_HISTORY_REQUEST,
  MANIFEST_HISTORY_SUCCESS,
  MANIFEST_HISTORY_FAILURE,
} from '../ManifestConstants';

describe('manifest actions', () => {
  it('creates loadManifestHistory API action', () => {
    expect(loadManifestHistory({ page: 1 })).toMatchObject({
      type: API_OPERATIONS.GET,
      payload: {
        key: MANIFEST_HISTORY_KEY,
        url: '/katello/api/v2/organizations/1/subscriptions/manifest_history',
        params: { page: 1 },
        actionTypes: {
          REQUEST: MANIFEST_HISTORY_REQUEST,
          SUCCESS: MANIFEST_HISTORY_SUCCESS,
          FAILURE: MANIFEST_HISTORY_FAILURE,
        },
      },
    });
  });

  it('creates uploadManifest API action', () => {
    const file = new Blob(['manifest']);
    expect(uploadManifest(file)).toMatchObject({
      type: API_OPERATIONS.POST,
      payload: {
        key: UPLOAD_MANIFEST_KEY,
        url: '/katello/api/v2/organizations/1/subscriptions/upload',
        actionTypes: {
          REQUEST: UPLOAD_MANIFEST_REQUEST,
          SUCCESS: UPLOAD_MANIFEST_SUCCESS,
          FAILURE: UPLOAD_MANIFEST_FAILURE,
        },
      },
    });
  });

  it('creates refreshManifest API action', () => {
    expect(refreshManifest()).toMatchObject({
      type: API_OPERATIONS.PUT,
      payload: {
        key: REFRESH_MANIFEST_KEY,
        url: '/katello/api/v2/organizations/1/subscriptions/refresh_manifest',
        actionTypes: {
          REQUEST: REFRESH_MANIFEST_REQUEST,
          SUCCESS: REFRESH_MANIFEST_SUCCESS,
          FAILURE: REFRESH_MANIFEST_FAILURE,
        },
      },
    });
  });

  it('creates deleteManifest API action', () => {
    expect(deleteManifest()).toMatchObject({
      type: API_OPERATIONS.POST,
      payload: {
        key: DELETE_MANIFEST_KEY,
        url: '/katello/api/v2/organizations/1/subscriptions/delete_manifest',
        actionTypes: {
          REQUEST: DELETE_MANIFEST_REQUEST,
          SUCCESS: DELETE_MANIFEST_SUCCESS,
          FAILURE: DELETE_MANIFEST_FAILURE,
        },
      },
    });
  });
});
