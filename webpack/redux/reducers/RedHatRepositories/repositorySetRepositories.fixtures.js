import Immutable from '@theforeman/vendor/seamless-immutable';

import { normalizeContentSetRepositories } from '../../actions/RedHatRepositories/repositorySetRepositories';

export const contentId = 12;
export const productId = 10;
export const enabledIndex = 2;

export const initialState = Immutable({});

export const loadingState = Immutable({
  [contentId]: {
    loading: true,
    repositories: [],
    error: null,
  },
});

export const requestSuccessResponse = Immutable({
  total: 6,
  subtotal: 6,
  page: null,
  per_page: null,
  error: null,
  search: null,
  sort: {
    by: null,
    order: null,
  },
  results: [
    {
      substitutions: {
        releasever: '7.0',
        basearch: 'x86_64',
      },
      path: '/content/dist/rhel/server/7/7.0/x86_64/supplementary/os',
      repo_name: 'Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7.0',
      name: 'Red Hat Enterprise Linux 7 Server - Supplementary (RPMs)',
      pulp_id:
        'Default_Organization-Red_Hat_Enterprise_Linux_Server-Red_Hat_Enterprise_Linux_7_Server_-_Supplementary_RPMs_x86_64_7_0',
      enabled: false,
      promoted: false,
    },
    {
      substitutions: {
        releasever: '7.1',
        basearch: 'x86_64',
      },
      path: '/content/dist/rhel/server/7/7.1/x86_64/supplementary/os',
      repo_name: 'Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7.1',
      name: 'Red Hat Enterprise Linux 7 Server - Supplementary (RPMs)',
      pulp_id:
        'Default_Organization-Red_Hat_Enterprise_Linux_Server-Red_Hat_Enterprise_Linux_7_Server_-_Supplementary_RPMs_x86_64_7_1',
      enabled: false,
      promoted: false,
    },
    {
      substitutions: {
        releasever: '7.2',
        basearch: 'x86_64',
      },
      path: '/content/dist/rhel/server/7/7.2/x86_64/supplementary/os',
      repo_name: 'Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7.2',
      name: 'Red Hat Enterprise Linux 7 Server - Supplementary (RPMs)',
      pulp_id:
        'Default_Organization-Red_Hat_Enterprise_Linux_Server-Red_Hat_Enterprise_Linux_7_Server_-_Supplementary_RPMs_x86_64_7_2',
      enabled: false,
      promoted: false,
    },
    {
      substitutions: {
        releasever: '7.3',
        basearch: 'x86_64',
      },
      path: '/content/dist/rhel/server/7/7.3/x86_64/supplementary/os',
      repo_name: 'Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7.3',
      name: 'Red Hat Enterprise Linux 7 Server - Supplementary (RPMs)',
      pulp_id:
        'Default_Organization-Red_Hat_Enterprise_Linux_Server-Red_Hat_Enterprise_Linux_7_Server_-_Supplementary_RPMs_x86_64_7_3',
      enabled: false,
      promoted: false,
    },
    {
      substitutions: {
        releasever: '7.4',
        basearch: 'x86_64',
      },
      path: '/content/dist/rhel/server/7/7.4/x86_64/supplementary/os',
      repo_name: 'Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7.4',
      name: 'Red Hat Enterprise Linux 7 Server - Supplementary (RPMs)',
      pulp_id:
        'Default_Organization-Red_Hat_Enterprise_Linux_Server-Red_Hat_Enterprise_Linux_7_Server_-_Supplementary_RPMs_x86_64_7_4',
      enabled: false,
      promoted: false,
    },
    {
      substitutions: {
        releasever: '7Server',
        basearch: 'x86_64',
      },
      path: '/content/dist/rhel/server/7/7Server/x86_64/supplementary/os',
      repo_name: 'Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7Server',
      name: 'Red Hat Enterprise Linux 7 Server - Supplementary (RPMs)',
      pulp_id:
        'Default_Organization-Red_Hat_Enterprise_Linux_Server-Red_Hat_Enterprise_Linux_7_Server_-_Supplementary_RPMs_x86_64_7Server',
      enabled: false,
      promoted: false,
    },
  ],
});

export const successState = Immutable({
  [contentId]: {
    loading: false,
    repositories: normalizeContentSetRepositories(
      requestSuccessResponse.results,
      contentId,
      productId,
    ),
    error: null,
  },
});

export const errorState = Immutable({
  [contentId]: {
    loading: false,
    repositories: [],
    error: 'Unable to process request.',
  },
});

export const enabledState = successState.setIn(
  [contentId, 'repositories', enabledIndex, 'enabled'],
  true,
);

export const enablingState = successState.setIn(
  [contentId, 'repositories', enabledIndex, 'loading'],
  true,
);

export const enablingFailedState = successState.setIn(
  [contentId, 'repositories', enabledIndex, 'error'],
  true,
);
