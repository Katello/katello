import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  loading: false,
});

export const loadingState = Immutable({
  loading: true,
});

export const requestSuccessResponse = Immutable({
  label: 'Default_Organization',
  owner_details: {
    parentOwner: null,
    id: 'ff8080815ea5ea44015ea5f0eb5c0001',
    key: 'Default_Organization',
    displayName: 'Default Organization',
    contentPrefix: '/Default_Organization/$env',
    defaultServiceLevel: null,
    upstreamConsumer: null,
  },
  redhat_repository_url: 'https://cdn.redhat.com',
  service_levels: [],
  service_level: null,
  select_all_types: [],
  description: null,
  created_at: '2017-09-21 15:36:18 -0400',
  updated_at: '2017-09-21 15:36:18 -0400',
  ancestry: null,
  parent_id: null,
  parent_name: null,
  id: 1,
  name: 'Default Organization',
  title: 'Default Organization',
  users: [],
  smart_proxies: [],
  subnets: [],
  compute_resources: [],
  media: [],
  config_templates: [],
  ptables: [],
  provisioning_templates: [],
  domains: [],
  realms: [],
  environments: [],
  hostgroups: [],
  locations: [],
  hosts_count: 2,
  parameters: [],
  default_content_view_id: 1,
  library_id: 1,
});

export const successState = Immutable({ loading: false, ...requestSuccessResponse });

export const errorState = Immutable({
  error: 'Unable to process request.',
});


export const getSuccessActions = [
  {
    type: 'GET_ORGANIZATION_REQUEST',
  },
  {
    response: requestSuccessResponse,
    type: 'GET_ORGANIZATION_SUCCESS',
  },
];

export const getFailureActions = [
  {
    type: 'GET_ORGANIZATION_REQUEST',
  },
  {
    error: new Error('Request failed with status code 422'),
    type: 'GET_ORGANIZATION_FAILURE',
  },
];
