import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  loading: true,
  results: [],
});

export const loadingState = Immutable({
  loading: true,
  results: [],
});

export const requestSuccessResponse = Immutable({
  total: 5,
  subtotal: 5,
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
  results: requestSuccessResponse.results,
  searchIsActive: false,
});

export const errorState = Immutable({
  loading: false,
  error: 'Unable to process request.',
});
