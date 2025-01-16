import Immutable from 'seamless-immutable';

const bootedContainerImagesResponse = Immutable({
  total: 2,
  page: 1,
  per_page: 20,
  subtotal: 2,
  results: [
    {
      bootc_booted_image: 'quay.io/centos-bootc/centos-bootc:stream10',
      digests: [
        {
          bootc_booted_digest: 'sha256:54256a998f0c62e16f3927c82b570f90bd8449a52e03daabd5fd16d6419fd572',
          host_count: 1,
        },
        {
          bootc_booted_digest: 'sha256:54256a998f0c62e16f3927c82b570f90bd8449a52e03daabd5fd16d6419fd573',
          host_count: 2,
        },
        {
          bootc_booted_digest: 'sha256:54256a998f0c62e16f3927c82b570f90bd8449a52e03daabd5fd16d6419fd574',
          host_count: 3,
        },
        {
          bootc_booted_digest: 'sha256:54256a998f0c62e16f3927c82b570f90bd8449a52e03daabd5fd16d6419fd575',
          host_count: 4,
        },
      ],
    },
    {
      bootc_booted_image: 'quay.io/centos-bootc/centos-bootc:stream9',
      digests: [
        {
          bootc_booted_digest: 'sha256:54256a998f0c62e16f3927c82b570f90bd8449a52e03daabd5fd16d6419fd576',
          host_count: 6,
        },
      ],
    },
  ],
});

export default bootedContainerImagesResponse;
