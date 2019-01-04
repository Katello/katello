import Immutable from '@theforeman/vendor/seamless-immutable';
import { initialApiState } from '../../../../services/api';

export const initialState = initialApiState;

export const details = {
  id: 22,
  name: 'avocado',
  uuid: '8ae7f190-0a48-41a2-93e0-7bc3e4734355',
  version: '20180816135607',
  context: 'a5b0195c',
  stream: 'latest',
  arch: 'x86_64',
  description: 'Avocado is a set of tools and libraries (what people call these days a framework) to perform automated testing.',
  summary: 'Framework with tools and libraries for Automated Testing',
  artifacts: [
    {
      id: 208,
      name: 'python3-avocado-plugins-varianter-yaml-to-mux-0:63.0-2.module_2037+1b0ad681.noarch',
    },
    {
      id: 207,
      name: 'python3-avocado-plugins-varianter-pict-0:63.0-2.module_2037+1b0ad681.noarch',
    },
  ],
  profiles: [
    {
      id: 37,
      name: 'default',
      rpms: [
        {
          id: 108,
          name: 'perl',
        },
        {
          id: 110,
          name: 'foo',
        },
        {
          id: 111,
          name: 'rpm_0',
        },
        {
          id: 112,
          name: 'rpm_1',
        },
        {
          id: 113,
          name: 'rpm_2',
        },
        {
          id: 114,
          name: 'rpm_3',
        },
        {
          id: 115,
          name: 'rpm_4',
        },
        {
          id: 116,
          name: 'rpm_5',
        },
        {
          id: 117,
          name: 'rpm_6',
        },
        {
          id: 118,
          name: 'rpm_7',
        },
        {
          id: 119,
          name: 'rpm_8',
        },
        {
          id: 120,
          name: 'rpm_9',
        },
        {
          id: 121,
          name: 'rpm_10',
        },
      ],
    },
    {
      id: 38,
      name: 'minimal',
      rpms: [
        {
          id: 84,
          name: 'python2-avocado',
        },
      ],
    },
  ],
  repositories: [
    {
      id: 1,
      name: 'rawhide_wtih_modules',
      product_id: 1,
      product_name: 'fedora',
    },
    {
      id: 4,
      name: 'rawhide_wtih_modules_dup',
      product_id: 1,
      product_name: 'fedora',
    },
  ],
};

export const loadingState = Immutable({
  ...initialState,
  loading: true,
});
