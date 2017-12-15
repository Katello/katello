export default [
  {
    path: '/katello/api/v2/products/:id/repository_sets/:repo_set_id/enable',
    searchRegex: /\/katello\/api\/v2\/products\/\d+\/repository_sets\/\d+\/enable/,
    type: 'PUT',
    response: () => {
      const types = ['yum', 'source_rpm', 'debug', 'iso', 'beta', 'kickstart'];

      const output = {
        id: Math.round(Math.random() * 500),
        name: 'Red Hat Enterprise Linux 6.2 Server for RHS 2 VSA Beta RPMs from RHUI x86_64',
        content_type: types[Math.floor(Math.random() * types.length)],
      };

      return [
        200,
        {
          id: 'd4a4432e-4987-4206-aa99-615b5b15fbf8',
          label: 'Actions::Katello::RepositorySet::EnableRepository',
          pending: false,
          username: 'admin',
          started_at: '2017-12-19 14:33:41 UTC',
          ended_at: '2017-12-19 14:33:44 UTC',
          state: 'stopped',
          result: 'success',
          progress: 1.0,
          input: {
            services_checked: ['pulp', 'pulp_auth', 'candlepin', 'candlepin_auth'],
            repository: {
              id: 7,
              name: 'Red Hat Enterprise Linux 6.2 Server for RHS 2 VSA Beta RPMs from RHUI x86_64',
              label: 'Red_Hat_Enterprise_Linux_6_2_Server_for_RHS_2_VSA_Beta_RPMs_from_RHUI_x86_64',
            },
            product: {
              id: 155,
              name: 'Red Hat Storage',
              label: 'Red_Hat_Storage',
              cp_id: '171',
            },
            provider: {
              id: 2,
              name: 'Red Hat',
            },
            organization: {
              id: 1,
              name: 'Default Organization',
              label: 'Default_Organization',
            },
          },
          output,
          humanized: {
            action: 'Enable',
            input: [],
            output: '',
            errors: [],
          },
          cli_example: null,
        },
      ];
    },
  },
  {
    path: '/katello/api/v2/products/:id/repository_sets/:repo_set_id/disable',
    searchRegex: /\/katello\/api\/v2\/products\/\d+\/repository_sets\/\d+\/disable/,
    type: 'PUT',
    response: () => [
      200,
      {
        id: 'd4a4432e-4987-4206-aa99-615b5b15fbf8',
        label: 'Actions::Katello::RepositorySet::DisableRepository',
        pending: false,
        username: 'admin',
        started_at: '2017-12-19 14:33:41 UTC',
        ended_at: '2017-12-19 14:33:44 UTC',
        state: 'stopped',
        result: 'success',
        progress: 1.0,
        input: {
          services_checked: ['pulp', 'pulp_auth', 'candlepin', 'candlepin_auth'],
          repository: {
            id: 7,
            name: 'Red Hat Enterprise Linux 6.2 Server for RHS 2 VSA Beta RPMs from RHUI x86_64',
            label: 'Red_Hat_Enterprise_Linux_6_2_Server_for_RHS_2_VSA_Beta_RPMs_from_RHUI_x86_64',
          },
          product: {
            id: 155,
            name: 'Red Hat Storage',
            label: 'Red_Hat_Storage',
            cp_id: '171',
          },
          provider: {
            id: 2,
            name: 'Red Hat',
          },
          organization: {
            id: 1,
            name: 'Default Organization',
            label: 'Default_Organization',
          },
        },
        output: {},
        humanized: {
          action: 'Disable',
          input: [],
          output: '',
          errors: [],
        },
        cli_example: null,
      },
    ],
  },
  {
    path: '/organizations/:id/repository_sets',
    searchRegex: /\/organizations\/\d+\/repository_sets$/,
    response: () => [
      200,
      {
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
      },
    ],
  },
  {
    // Returns the currently enabled repositories
    path: '/repository_sets?organization_id=:id',
    searchRegex: /\/organizations\/\d+\/repository_sets/,
    response: () => [
      200,
      {
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
      },
    ],
  },
  {
    path: '/products/:product_id/repository_sets/:content_id/available_repositories',
    searchRegex: /\/products\/\d+\/repository_sets\/\d+\/available_repositories/,
    response: () => [
      200,
      {
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
      },
    ],
  },
];
