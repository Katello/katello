import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  loading: false,
  results: [],
});

export const loadingState = Immutable({
  loading: true,
  results: [],
});

export const getTaskSuccessResponse = Immutable({
  id: 'eb1b6271-8a69-4d98-84fc-bea06ddcc166',
  label: 'Actions::Katello::Organization::ManifestRefresh',
  pending: false,
  username: 'admin',
  started_at: '2018-04-15 16:53:05 -0400',
  ended_at: null,
  state: 'running',
  result: 'pending',
  progress: 0.09074410163339383,
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

export const getTaskPendingResponse = {
  ...getTaskSuccessResponse,
  pending: true,
};

export const bulkSearchSuccessResponse = Immutable([
  {
    search_params: {
      search_id: 'pollBulkSearch',
      type: 'all',
      active_only: true,
      action_types: [
        'Actions::Katello::Organization::ManifestImport',
        'Actions::Katello::Organization::ManifestRefresh',
        'Actions::Katello::Organization::ManifestDelete',
      ],
    },
    results: [getTaskSuccessResponse],
  },
]);

export const successState = Immutable({
  loading: false,
  results: bulkSearchSuccessResponse,
});

export const errorState = Immutable({
  loading: false,
  error: 'Unable to process request.',
  results: [],
});

export const bulkSearchSuccessActions = [
  {
    type: 'TASK_BULK_SEARCH_REQUEST',
  },
  {
    response: bulkSearchSuccessResponse,
    type: 'TASK_BULK_SEARCH_SUCCESS',
  },
];

export const bulkSearchCancelledActions = [
  {
    type: 'TASK_BULK_SEARCH_CANCELLED',
  },
];

export const bulkSearchSkippedActions = [
  {
    type: 'TASK_BULK_SEARCH_SKIPPED',
  },
];

export const buildBulkSearchFailureActions = (errorCode = 422) => ([
  {
    type: 'TASK_BULK_SEARCH_REQUEST',
  },
  {
    result: new Error(`Request failed with status code ${errorCode}`),
    type: 'TASK_BULK_SEARCH_FAILURE',
  },
]);

export const pollTaskStartedActions = [
  {
    type: 'POLL_TASK_STARTED',
  },
];

export const buildTaskSuccessActions = response => ([
  {
    type: 'GET_TASK_REQUEST',
  },
  {
    response,
    type: 'GET_TASK_SUCCESS',
  },
]);

export const buildPollTaskSuccessActions = response => pollTaskStartedActions
  .concat(buildTaskSuccessActions(response));

export const getPollTaskSuccessActions = buildPollTaskSuccessActions(getTaskSuccessResponse);

export const getTaskSuccessActions = buildTaskSuccessActions(getTaskSuccessResponse);

export const getTaskPendingActions = buildTaskSuccessActions(getTaskPendingResponse);

export const buildTaskFailureActions = (errorCode = 422) => ([
  {
    type: 'GET_TASK_REQUEST',
  },
  {
    result: new Error(`Request failed with status code ${errorCode}`),
    type: 'GET_TASK_FAILURE',
  },
]);

