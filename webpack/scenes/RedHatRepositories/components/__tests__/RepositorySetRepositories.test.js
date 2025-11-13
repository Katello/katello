import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import nock from 'nock';

import ConnectedRepositorySetRepositories from '../RepositorySetRepositories';
import api from '../../../../services/api';
import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';

import apiResponseData from './repositorySetRepositoriesAPI.fixtures.json';

const contentId = 1;
const productId = 2;
const apiPath = api.getApiUrl(`/products/${productId}/repository_sets/${contentId}/available_repositories`);

const getInitialState = () => ({
  katello: {
    redHatRepositories: {
      repositorySetRepositories: {},
      enabled: {
        pagination: {
          page: 1,
          perPage: 20,
        },
        search: {},
      },
    },
  },
});

describe('RepositorySetRepositories Component', () => {
  afterEach(() => {
    nock.cleanAll();
  });

  test('loads and displays repository list with multiple architectures and versions', async () => {
    const scope = nockInstance
      .get(apiPath)
      .query(true)
      .reply(200, apiResponseData);

    const { queryByText, getByText, container } = renderWithRedux(
      <ConnectedRepositorySetRepositories contentId={contentId} productId={productId} />,
      getInitialState(),
    );

    // Initially should show loading or nothing
    expect(queryByText('x86_64 7.0')).not.toBeInTheDocument();

    // Wait for API call to complete and repositories to render
    await patientlyWaitFor(() => {
      // Verify x86_64 repositories are displayed with their release versions
      expect(getByText('x86_64 7.0')).toBeInTheDocument();
      expect(getByText('x86_64 7.1')).toBeInTheDocument();
      expect(getByText('x86_64 7.10')).toBeInTheDocument();
      expect(getByText('x86_64 7.11')).toBeInTheDocument();
      expect(getByText('x86_64 7Server')).toBeInTheDocument();

      // Verify i386 repositories are displayed
      expect(getByText('i386 5.11')).toBeInTheDocument();
      expect(getByText('i386 5Workstation')).toBeInTheDocument();
    });

    // querySelector is acceptable here for legacy PatternFly 3 ListView component
    // which doesn't provide accessible role attributes for list items
    const listItems = container.querySelectorAll('.list-view-pf-main-info');
    expect(listItems).toHaveLength(7);

    assertNockRequest(scope);
  });

  test('displays multiple repositories with different architectures', async () => {
    const testContentId = 2;
    const testApiPath = api.getApiUrl(`/products/${productId}/repository_sets/${testContentId}/available_repositories`);
    const scope = nockInstance
      .get(testApiPath)
      .query(true)
      .reply(200, apiResponseData);

    const { getByText } = renderWithRedux(
      <ConnectedRepositorySetRepositories contentId={testContentId} productId={productId} />,
      getInitialState(),
    );

    await patientlyWaitFor(() => {
      // Verify both x86_64 and i386 repositories are displayed
      expect(getByText('x86_64 7.0')).toBeInTheDocument();
      expect(getByText('i386 5.11')).toBeInTheDocument();
    });

    assertNockRequest(scope);
  });

  test('handles API errors gracefully', async () => {
    const testContentId = 3;
    const testApiPath = api.getApiUrl(`/products/${productId}/repository_sets/${testContentId}/available_repositories`);
    const scope = nockInstance
      .get(testApiPath)
      .query(true)
      .reply(500, { error: 'Server error' });

    const { queryByText } = renderWithRedux(
      <ConnectedRepositorySetRepositories contentId={testContentId} productId={productId} />,
      getInitialState(),
    );

    await patientlyWaitFor(() => {
      // Should not display repository data after error
      expect(queryByText('x86_64 7.0')).not.toBeInTheDocument();
    });

    assertNockRequest(scope);
  });
});
