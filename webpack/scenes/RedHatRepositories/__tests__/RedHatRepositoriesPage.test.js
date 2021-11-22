import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import RedHatRepositoriesPage from '../RedHatRepositoriesPage';

jest.mock('foremanReact/components/PermissionDenied');

describe('RedHatRepositories page', () => {
  const page = shallow(<RedHatRepositoriesPage
    loadEnabledRepos={jest.fn()}
    loadRepositorySets={jest.fn()}
    loadOrganization={jest.fn()}
    updateRecommendedRepositorySets={jest.fn()}
    enabledRepositories={{
      loading: false,
      search: {},
      missingPermissions: [],
      repositories: [],
    }}
    repositorySets={{
      recommended: false,
      loading: false,
      search: {},
      missingPermissions: [],
    }}
    organization={{
      id: 1000,
      cdn_configuration: {
        type: 'redhat_cdn',
        url: 'http://cdn.example.com',
      },
    }}
  />);

  const permissionDeniedPage = shallow(<RedHatRepositoriesPage
    loadEnabledRepos={jest.fn()}
    loadRepositorySets={jest.fn()}
    loadOrganization={jest.fn()}
    updateRecommendedRepositorySets={jest.fn()}
    enabledRepositories={{
      loading: false,
      search: {},
      missingPermissions: ['view_organizations'],
    }}
    repositorySets={{
      recommended: false,
      loading: false,
      search: {},
      missingPermissions: ['view_organizations'],
    }}
    organization={{
      id: 1000,
      cdn_configuration: {
        type: 'redhat_cdn',
        url: 'http://cdn.example.com',
      },
    }}
  />);

  it('should render', async () => {
    expect(toJson(page)).toMatchSnapshot();
  });

  it('should render <PermissionDenied /> when permissions are missing', async () => {
    expect(toJson(permissionDeniedPage)).toMatchSnapshot();
  });
});
