import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  loading: false,
  error: null,
  results: [],
});

export const loadingState = Immutable({
  ...initialState,
  loading: true,
});

export const results = [
  {
    id: 340,
    cp_id: '607918016883',
    name: 'Custom Product',
    label: 'custom_product',
    description: 'A custom product for testing',
    provider_id: 1,
    sync_plan_id: null,
    sync_summary: {},
    gpg_key_id: null,
    ssl_ca_cert_id: null,
    ssl_client_cert_id: null,
    ssl_client_key_id: null,
    sync_state: null,
    last_sync: '2022-07-25 09:31:37 -0400',
    last_sync_words: '1 day',
    organization_id: 1,
    organization: {
      name: 'Default Organization',
      label: 'Default_Organization',
      id: 1,
    },
    sync_plan: null,
    repository_count: 2,
  },
  {
    id: 19,
    cp_id: '479',
    name: 'Red Hat Enterprise Linux for x86_64',
    label: 'Red_Hat_Enterprise_Linux_for_x86_64',
    description: null,
    provider_id: 2,
    sync_plan_id: null,
    sync_summary: {
      success: 2,
    },
    gpg_key_id: null,
    ssl_ca_cert_id: null,
    ssl_client_cert_id: null,
    ssl_client_key_id: null,
    sync_state: 'Syncing Complete.',
    last_sync: '2022-07-22 13:49:39 -0400',
    last_sync_words: '4 days',
    organization_id: 1,
    organization: {
      name: 'Default Organization',
      label: 'Default_Organization',
      id: 1,
    },
    sync_plan: null,
    repository_count: 2,
  },
  {
    id: 341,
    cp_id: '805147203918',
    name: 'Yummy Product',
    label: 'yummy_product',
    description: 'A yummy product',
    provider_id: 1,
    sync_plan_id: null,
    sync_summary: {},
    gpg_key_id: null,
    ssl_ca_cert_id: null,
    ssl_client_cert_id: null,
    ssl_client_key_id: null,
    sync_state: null,
    last_sync: '2022-07-25 21:25:33 -0400',
    last_sync_words: 'about 15 hours',
    organization_id: 1,
    organization: {
      name: 'Default Organization',
      label: 'Default_Organization',
      id: 1,
    },
    sync_plan: null,
    repository_count: 1,
  },
];

export const successState = Immutable({
  loading: false,
  error: null,
  results,
});

export const requestSuccessResponse = {
  results,
};

export const getSuccessActions = (orgId = 1) => [
  {
    type: 'ORGANIZATION_PRODUCTS_REQUEST',
  },
  {
    type: 'ORGANIZATION_PRODUCTS_SUCCESS',
    payload: {
      orgId,
      results,
    },
  },
];

export const getFailureActions = () => {
  const errorMessage = 'Request failed with status code 500';
  return [
    {
      type: 'ORGANIZATION_PRODUCTS_REQUEST',
    },
    {
      type: 'ORGANIZATION_PRODUCTS_FAILURE',
      payload: {
        result: new Error(errorMessage),
        messages: [errorMessage],
      },
    },
    {
      type: 'toasts/addToast',
      payload: {
        key: 'addToast',
        toast: {
          key: 'toastError_0',
          message: errorMessage,
          sticky: true,
          type: 'danger',
        },
      },
    },
  ];
};
