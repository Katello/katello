import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  loading: true,
  recommended: false,
  results: [],
  pagination: {
    page: 0,
  },
  itemCount: 0,
});

export const recommendedState = Immutable({
  loading: true,
  recommended: true,
  results: [],
  pagination: {
    page: 0,
  },
  itemCount: 0,
});

export const loadingState = Immutable({
  loading: true,
  recommended: false,
  results: [],
  pagination: {
    page: 0,
  },
  itemCount: 0,
});

export const requestSuccessResponse = Immutable({
  total: 15,
  subtotal: 10,
  page: 1,
  per_page: 5,
  error: null,
  search: 'name ~ Server',
  sort: {
    by: null,
    order: null,
  },
  results: [
    {
      repositories: [],
      product: {
        name: 'Red hat Enterprise Linux Server 7',
        id: 5,
      },
      type: 'file',
      vendor: 'Red Hat',
      gpgUrl: 'http://',
      contentUrl: '/content/dist/rhel/server/7///source/iso',
      id: '2457',
      name: 'Red Hat Enterprise Linux 7 Server (Source ISOs)',
      label: 'rhel-7-server-source-isos',
    },
    {
      repositories: [],
      type: 'yum',
      product: {
        name: 'Red hat Enterprise Linux Server 7',
        id: 5,
      },
      vendor: 'Red Hat',
      gpgUrl: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release',
      contentUrl: '/content/dist/rhel/server/6/6Server//sat-tools/6.1/source/SRPMS',
      id: '4187',
      name: 'Red Hat Satellite Tools 6.1 (for RHEL 6 Server) (Source RPMs)',
      label: 'rhel-6-server-satellite-tools-6.1-source-rpms',
    },
    {
      repositories: [],
      type: 'yum',
      product: {
        name: 'Red hat Enterprise Linux Server 7',
        id: 5,
      },
      vendor: 'Red Hat',
      gpgUrl:
        'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta,file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release',
      contentUrl: '/content/beta/rhel/server/6/6Server//rh-common/os',
      id: '3076',
      name: 'Red Hat Enterprise Linux 6 Server - RH Common Beta (RPMs)',
      label: 'rhel-6-server-rh-common-beta-rpms',
    },
    {
      repositories: [],
      type: 'yum',
      product: {
        name: 'Red hat Enterprise Linux Server 7',
        id: 5,
      },
      vendor: 'Red Hat',
      gpgUrl: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release',
      contentUrl: '/content/dist/rhel/server/6///rhev-agent/3/os',
      id: '1699',
      name: 'Red Hat Enterprise Virtualization Agents for RHEL 6 Server (RPMs)',
      label: 'rhel-6-server-rhev-agent-rpms',
    },
    {
      repositories: [
        {
          id: 631,
          name: 'Red Hat Enterprise Linux 6 Server Kickstart x86_64 6.8',
          releasever: '6.8',
          arch: 'x86_64',
        },
      ],
      product: {
        name: 'Red hat Enterprise Linux Server 7',
        id: 5,
      },
      type: 'kickstart',
      vendor: 'Red Hat',
      gpgUrl: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release',
      contentUrl: '/content/dist/rhel/server/6///kickstart',
      id: '1952',
      name: 'Red Hat Enterprise Linux 6 Server (Kickstart)',
      label: 'rhel-6-server-kickstart',
    },
  ],
});

export const successState = Immutable({
  loading: false,
  recommended: false,
  results: requestSuccessResponse.results,
  searchIsActive: true,
  search: requestSuccessResponse.search,
  pagination: {
    page: 1,
    perPage: 5,
  },
  itemCount: 10,
});

export const errorState = Immutable({
  error: { response: { data: { error: { missing_permissions: ['unknown'] } } } },
  loading: false,
  missingPermissions: ['unknown'],
});
