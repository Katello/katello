import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import RedHatRepositoriesPage from '../RedHatRepositoriesPage';

jest.mock('foremanReact/components/PermissionDenied');

describe('RedHatRepositories page', () => {
  const page = shallow(<RedHatRepositoriesPage
    loadEnabledRepos={jest.fn()}
    loadRepositorySets={jest.fn()}
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
  />);

  const permissionDeniedPage = shallow(<RedHatRepositoriesPage
    loadEnabledRepos={jest.fn()}
    loadRepositorySets={jest.fn()}
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
  />);

  it('should render', async () => {
    expect(toJson(page)).toMatchSnapshot();
  });

  it('should render <PermissionDenied /> when permissions are missing', async () => {
    expect(toJson(permissionDeniedPage)).toMatchSnapshot();
  });
});
