import Immutable from 'seamless-immutable';
import { toastErrorAction, failureAction } from '../../../../services/api/testHelpers';

export const manifestHistoryInitialState = Immutable({
  loading: true,
  results: [],
});

export const manifestHistoryLoadingState = Immutable({
  loading: true,
  results: [],
});

export const manifestHistoryErrorState = Immutable({
  loading: false,
  error: 'Unable to process request.',
  results: [],
});

export const manifestActionsInitialState = Immutable({
  pending: false,
});

export const manifestActionsLoadingState = Immutable({
  pending: true,
  progress: 0,
});

export const manifestActionsErrorState = Immutable({
  pending: false,
  error: 'Unable to process request.',
});

export const manifestHistorySuccessResponse = Immutable([
  {
    statusMessage: 'Default_Organization file imported successfully.',
    status: 'SUCCESS',
    created: '2018-04-12T18:58:45+0000',
  },
  {
    statusMessage: 'Default_Organization file imported successfully.',
    status: 'SUCCESS',
    created: '2018-04-12T14:28:57+0000',
  },
  {
    statusMessage: 'Default_Organization file imported successfully.',
    status: 'SUCCESS',
    created: '2018-04-11T14:36:43+0000',
  },
  {
    statusMessage: 'Default_Organization file imported successfully.',
    status: 'SUCCESS',
    created: '2018-04-11T04:29:51+0000',
  },
  {
    statusMessage: 'Default_Organization file imported successfully.',
    status: 'SUCCESS',
    created: '2018-04-11T04:26:38+0000',
  },
  {
    statusMessage: 'Default_Organization file imported successfully.',
    status: 'SUCCESS',
    created: '2018-04-11T04:23:05+0000',
  },
  {
    statusMessage: 'Default_Organization file imported successfully.',
    status: 'SUCCESS',
    created: '2018-04-11T04:05:07+0000',
  },
  {
    statusMessage: 'Default_Organization file imported successfully.',
    status: 'SUCCESS',
    created: '2018-04-11T03:29:44+0000',
  },
  {
    statusMessage: 'Default_Organization file imported successfully.',
    status: 'SUCCESS',
    created: '2018-04-10T18:44:38+0000',
  },
  {
    statusMessage: 'Default_Organization file imported successfully.',
    status: 'SUCCESS',
    created: '2018-04-10T18:40:17+0000',
  },
]);

export const taskSuccessResponse = Immutable({
  id: 'c6e7dd0b-1d40-4c75-b1e0-b193c4d0597f',
  label: 'Actions::Katello::Organization::ManifestRefresh',
  pending: false,
  username: 'admin',
  started_at: '2018-04-15 15:34:37 -0400',
  ended_at: null,
  state: 'planned',
  result: 'pending',
  progress: 0,
  input: {
    organization: {
      id: 1,
      name: 'Default Organization',
      label: 'Default_Organization',
    },
    services_checked: [
      'candlepin',
      'candlepin_auth',
      'pulp',
      'pulp_auth',
    ],
    remote_user: 'admin',
    remote_cp_user: 'admin',
    locale: 'en',
    current_user_id: 4,
  },
  output: {},
  humanized: {
    action: 'Refresh Manifest',
    input: [
      [
        'organization',
        {
          text: 'organization \'Default Organization\'',
          link: '/organizations/1/edit',
        },
      ],
    ],
    output: '',
    errors: [],
  },
  cli_example: null,
});

export const manifestHistorySuccessState = Immutable({
  loading: false,
  results: manifestHistorySuccessResponse,
});

export const manifestActionsSuccessState = taskSuccessResponse;

export const manifestHistorySuccessActions = [
  {
    type: 'MANIFEST_HISTORY_REQUEST',
  },
  {
    response: manifestHistorySuccessResponse,
    type: 'MANIFEST_HISTORY_SUCCESS',
  },
];

export const manifestHistoryFailureActions = [
  {
    type: 'MANIFEST_HISTORY_REQUEST',
  },
  failureAction('MANIFEST_HISTORY_FAILURE'),
  toastErrorAction(),
];

export const uploadManifestSuccessActions = [
  {
    type: 'UPLOAD_MANIFEST_REQUEST',
  },
  {
    response: taskSuccessResponse,
    type: 'UPLOAD_MANIFEST_SUCCESS',
  },
];

export const uploadManifestFailureActions = [
  {
    type: 'UPLOAD_MANIFEST_REQUEST',
  },
  failureAction('UPLOAD_MANIFEST_FAILURE'),
  toastErrorAction(),
];

export const refreshManifestSuccessActions = [
  {
    type: 'REFRESH_MANIFEST_REQUEST',
  },
  {
    response: taskSuccessResponse,
    type: 'REFRESH_MANIFEST_SUCCESS',
  },
];

export const refreshManifestFailureActions = [
  {
    type: 'REFRESH_MANIFEST_REQUEST',
  },
  failureAction('REFRESH_MANIFEST_FAILURE'),
  toastErrorAction(),
];

export const deleteManifestSuccessActions = [
  {
    type: 'DELETE_MANIFEST_REQUEST',
  },
  {
    response: taskSuccessResponse,
    type: 'DELETE_MANIFEST_SUCCESS',
  },
];

export const deleteManifestFailureActions = [
  {
    type: 'DELETE_MANIFEST_REQUEST',
  },
  failureAction('DELETE_MANIFEST_FAILURE'),
  toastErrorAction(),
];
