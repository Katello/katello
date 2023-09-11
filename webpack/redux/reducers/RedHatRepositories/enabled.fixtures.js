import Immutable from 'seamless-immutable';

export const disabledIndex = 1;

export const initialState = Immutable({
  loading: true,
  repositories: [],
  pagination: {
    page: 0,
  },
  itemCount: 0,
});

export const loadingState = Immutable({
  loading: true,
  repositories: [],
  pagination: {
    page: 0,
  },
  itemCount: 0,
});

export const requestSuccessResponse = Immutable({
  total: 15,
  subtotal: 2,
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
      content_type: 'yum',
      url: 'https://cdn.redhat.com/content/dist/rhel/server/7/7.0/x86_64/ceph-tools/1.3/os',
      relative_path: 'Default_Organization/Library/content/dist/rhel/server/7/7.0/x86_64/ceph-tools/1.3/os',
      arch: 'x86_64',
      backend_identifier: '24d30d8e-7e94-4744-9b1a-0c78b60ad66c',
      content_label: 'rhel-7-server-rhceph-1.3-tools-rpms',
      id: 2,
      name: 'Red Hat Ceph Storage Tools 1.3 for Red Hat Enterprise Linux 7 Server RPMs x86_64 7.0',
      label: 'Red_Hat_Ceph_Storage_Tools_1_3_for_Red_Hat_Enterprise_Linux_7_Server_RPMs_x86_64_7_0',
      product: {
        id: 20,
        cp_id: '69',
        name: 'Red Hat Enterprise Linux Server',
        sync_plan: [
          'name',
          'description',
          'sync_date',
          'interval',
          'next_sync',
        ],
      },
      last_sync: null,
      content_view_versions: [],
      content_counts: {
        docker_manifest: 0,
        docker_manifest_list: 0,
        docker_tag: 0,
        rpm: 0,
        srpm: 0,
        package: 0,
        package_group: 0,
        erratum: 0,
        file: 0,
        deb: 0,
      },
      content_id: '4455',
      major: '7',
      minor: '7.0',
      last_sync_words: null,
    },
    {
      content_type: 'yum',
      url: 'https://cdn.redhat.com/content/dist/rhel/server/7/7.1/x86_64/ceph-tools/1.3/os',
      relative_path: 'Default_Organization/Library/content/dist/rhel/server/7/7.1/x86_64/ceph-tools/1.3/os',
      arch: 'x86_64',
      backend_identifier: '70040489-7acf-47c8-89a2-1a29f664aab6',
      content_label: 'rhel-7-server-rhceph-1.3-tools-rpms',
      id: 4,
      name: 'Red Hat Ceph Storage Tools 1.3 for Red Hat Enterprise Linux 7 Server RPMs x86_64 7.1',
      label: 'Red_Hat_Ceph_Storage_Tools_1_3_for_Red_Hat_Enterprise_Linux_7_Server_RPMs_x86_64_7_1',
      product: {
        id: 20,
        cp_id: '69',
        name: 'Red Hat Enterprise Linux Server',
        sync_plan: [
          'name',
          'description',
          'sync_date',
          'interval',
          'next_sync',
        ],
      },
      last_sync: null,
      content_view_versions: [1],
      content_counts: {
        docker_manifest: 0,
        docker_manifest_list: 0,
        docker_tag: 0,
        rpm: 0,
        srpm: 0,
        package: 0,
        package_group: 0,
        erratum: 0,
        file: 0,
        deb: 0,
      },
      content_id: '4456',
      major: '7',
      minor: '7.1',
      last_sync_words: null,
    },
  ],
});

export const successState = Immutable({
  loading: false,
  repositories: [
    {
      arch: 'x86_64',
      contentId: 4455,
      id: 2,
      label: 'rhel-7-server-rhceph-1.3-tools-rpms',
      name: 'Red Hat Ceph Storage Tools 1.3 for Red Hat Enterprise Linux 7 Server RPMs x86_64 7.0',
      orphaned: undefined,
      productId: 20,
      releasever: '7.0',
      type: 'yum',
      canDisable: true,
    },
    {
      arch: 'x86_64',
      contentId: 4456,
      id: 4,
      label: 'rhel-7-server-rhceph-1.3-tools-rpms',
      name: 'Red Hat Ceph Storage Tools 1.3 for Red Hat Enterprise Linux 7 Server RPMs x86_64 7.1',
      orphaned: undefined,
      productId: 20,
      releasever: '7.1',
      type: 'yum',
      canDisable: false,
    },
  ],
  searchIsActive: false,
  search: undefined,
  pagination: {
    page: 1,
    perPage: 5,
  },
  itemCount: 2,
});

export const errorState = Immutable({
  loading: false,
  repositories: [],
  error: 'Unable to process request.',
  missingPermissions: ['unknown'],
});

export const disablingState = successState.setIn(
  ['repositories', disabledIndex, 'loading'],
  true,
);

export const disablingFailedState = successState.setIn(
  ['repositories', disabledIndex, 'loading'],
  false,
);
