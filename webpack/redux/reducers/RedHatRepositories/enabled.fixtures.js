import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  loading: true,
  repositories: [],
});

export const loadingState = Immutable({
  loading: true,
  repositories: [],
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
  repositories: [
    {
      type: 'kickstart',
      contentId: '1952',
      productId: 5,
      id: 631,
      name: 'Red Hat Enterprise Linux 6 Server Kickstart x86_64 6.8',
      releasever: '6.8',
      arch: 'x86_64',
    },
  ],
  searchIsActive: false,
});

export const errorState = Immutable({
  loading: false,
  repositories: [],
  error: 'Unable to process request.',
});
