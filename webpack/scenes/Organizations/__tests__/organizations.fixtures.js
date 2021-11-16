import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  loading: false,
});

export const loadingState = Immutable({
  loading: true,
});

export const updateCdnConfigurationSuccessResponse = Immutable({
  id: '6c536461-e7e3-421a-9d7a-780a39cd8fb4',
  label: 'Actions::Katello::CdnConfiguration::Update',
  pending: false,
  action: 'Update CDN Configuration',
  username: 'admin',
  started_at: '2021-11-16 12:00:46 -0500',
  ended_at: '2021-11-16 12:00:47 -0500',
  state: 'stopped',
  result: 'success',
  progress: 1,
  input: {
    locale: 'en',
    current_request_id: '7a0d7e03-ced1-4925-8790-79b73d25d29b',
    current_timezone: 'America/New_York',
    current_organization_id: 4,
    current_location_id: 2,
    current_user_id: 4,
  },
  output: {},
  humanized: {
    action: 'Update CDN Configuration',
    input: [],
    output: '',
    errors: [],
  },
  cli_example: null,
  start_at: '2021-11-16 12:00:46 -0500',
  available_actions: {
    cancellable: false,
    resumable: false,
  },
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
