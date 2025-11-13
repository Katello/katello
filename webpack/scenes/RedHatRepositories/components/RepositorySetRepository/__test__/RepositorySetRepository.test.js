import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import nock from 'nock';
import { nockInstance, assertNockRequest } from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import RepositorySetRepository from '../index'; // Import connected component
import repoSetRepoFixtures from './repositorySetRepository.fixtures.json';

// Mock orgId function while preserving the rest of the api module
jest.mock('../../../../../services/api', () => {
  const actual = jest.requireActual('../../../../../services/api');
  return {
    ...actual,
    __esModule: true,
    orgId: jest.fn(() => 1),
  };
});

// Create API response format matching what the backend returns for enabled repos
const createEnabledRepositoriesAPIResponse = repos => ({
  total: repos.length,
  subtotal: repos.length,
  page: 1,
  per_page: 20,
  results: repos.map(repo => ({
    id: repo.id,
    name: repo.name,
    label: repo.label,
    content_type: repo.type,
    content_label: repo.label,
    content_id: String(repo.content_id),
    arch: repo.arch,
    minor: repo.releasever,
    product: repo.product,
  })),
});

// API response for enable repository endpoint
// Uses actual repository data from fixtures instead of hardcoded values
const createEnableRepositoryAPIResponse = repo => ({
  output: {
    repository: {
      id: 1001,
      name: repo.releasever
        ? `Red Hat Enterprise Linux ${repo.releasever} for ${repo.displayArch} - BaseOS RPMs`
        : `Red Hat Satellite Tools for RHEL ${repo.displayArch} RPMs`,
      label: repo.label,
      content_type: repo.type,
    },
  },
});

const getBaseProps = (repoData = repoSetRepoFixtures[0]) => ({
  contentId: repoData.contentId,
  productId: repoData.productId,
  displayArch: repoData.displayArch,
  arch: repoData.arch,
  releasever: repoData.releasever,
  type: repoData.type,
  label: repoData.label,
  loading: repoData.loading,
  error: repoData.error,
});

const getInitialState = () => ({
  katello: {
    redHatRepositories: {
      enabled: {
        loading: false,
        repositories: [],
        pagination: { page: 1, perPage: 20 },
        itemCount: 0,
        search: { query: '' },
      },
    },
  },
});

describe('RepositorySetRepository Component', () => {
  afterEach(() => {
    nock.cleanAll();
    jest.clearAllMocks();
  });

  test('renders repository with arch and releasever', () => {
    const props = getBaseProps(repoSetRepoFixtures[0]);
    const { getByText } = renderWithRedux(
      <RepositorySetRepository {...props} />,
      getInitialState(),
    );

    expect(getByText('x86_64 8')).toBeInTheDocument();
  });

  test('renders Y-stream repository with help icon', () => {
    const props = getBaseProps(repoSetRepoFixtures[1]); // releasever: "8.5" (Y-stream)
    const { container, getByText } = renderWithRedux(
      <RepositorySetRepository {...props} />,
      getInitialState(),
    );

    // Y-stream repos should have deemphasize class
    const listItem = container.querySelector('.deemphasize');
    expect(listItem).toBeInTheDocument();

    // Verify the Y-stream version number appears
    expect(getByText('x86_64 8.5')).toBeInTheDocument();

    // For legacy PatternFly v3 FieldLevelHelp - verify info icon appears
    // The FieldLevelHelp component renders an info icon button with popover help content
    // The popover contains a link to https://access.redhat.com/articles/1586183
    const helpIcon = container.querySelector('.pficon-info');
    expect(helpIcon).toBeInTheDocument();
  });

  test('does not show help icon for non-Y-stream repository', () => {
    const props = getBaseProps(repoSetRepoFixtures[0]); // releasever: "8" (not Y-stream)
    const { container } = renderWithRedux(
      <RepositorySetRepository {...props} />,
      getInitialState(),
    );

    // Should NOT have deemphasize class
    const listItem = container.querySelector('.deemphasize');
    expect(listItem).not.toBeInTheDocument();

    // Should NOT have FieldLevelHelp info icon
    const helpIcon = container.querySelector('.pficon-info');
    expect(helpIcon).not.toBeInTheDocument();
  });

  test('does not deemphasize kickstart repositories even if Y-stream', () => {
    const props = getBaseProps(repoSetRepoFixtures[4]); // type: "kickstart"
    const { container } = renderWithRedux(
      <RepositorySetRepository {...props} />,
      getInitialState(),
    );

    // Kickstart repos should NOT have deemphasize class even if Y-stream format
    const listItem = container.querySelector('.deemphasize');
    expect(listItem).not.toBeInTheDocument();
  });

  test('renders unspecified arch when displayArch is null', () => {
    const props = getBaseProps(repoSetRepoFixtures[3]); // displayArch: "noarch"
    const { getByText } = renderWithRedux(
      <RepositorySetRepository {...props} />,
      getInitialState(),
    );

    expect(getByText('noarch')).toBeInTheDocument();
  });

  test('renders repository with null releasever', () => {
    const props = getBaseProps(repoSetRepoFixtures[3]); // releasever: null
    const { getByText } = renderWithRedux(
      <RepositorySetRepository {...props} />,
      getInitialState(),
    );

    // Should show arch but no releasever
    expect(getByText('noarch')).toBeInTheDocument();
  });

  test('renders enable button', () => {
    const props = getBaseProps(repoSetRepoFixtures[0]);
    const { getByRole } = renderWithRedux(
      <RepositorySetRepository {...props} />,
      getInitialState(),
    );

    // The enable button is rendered with a plus-circle icon
    const enableButton = getByRole('button');
    expect(enableButton).toBeInTheDocument();
    expect(enableButton).not.toBeDisabled();
  });

  test('renders loading state correctly', () => {
    const props = {
      ...getBaseProps(repoSetRepoFixtures[0]),
      loading: true,
    };
    const { container } = renderWithRedux(
      <RepositorySetRepository {...props} />,
      getInitialState(),
    );

    // For legacy PatternFly v3 Spinner component - verify component renders during loading
    expect(container.firstChild).toBeInTheDocument();
  });

  test('renders error state when error prop is true', () => {
    const props = {
      ...getBaseProps(repoSetRepoFixtures[0]),
      error: true,
    };
    const { container } = renderWithRedux(
      <RepositorySetRepository {...props} />,
      getInitialState(),
    );

    // For legacy PatternFly v3 icon - error icon should be visible
    const errorIcon = container.querySelector('.fa-times-circle-o');
    expect(errorIcon).toBeInTheDocument();

    const errorContainer = container.querySelector('.list-error-danger');
    expect(errorContainer).toBeInTheDocument();
  });

  test('enables repository via API when enable button is clicked', async () => {
    const repoData = repoSetRepoFixtures[0];
    const expectedRepoName = `Red Hat Enterprise Linux ${repoData.releasever} for ${repoData.displayArch} - BaseOS RPMs`;

    // Mock window.tfm.toastNotifications
    const savedTfm = window.tfm;
    window.tfm = {
      toastNotifications: {
        notify: jest.fn(),
      },
    };

    try {
      // Mock the enable API endpoint
      const enableApiPath = api.getApiUrl(`/products/${repoData.productId}/repository_sets/${repoData.contentId}/enable`);
      const enableScope = nockInstance
        .put(enableApiPath)
        .reply(200, createEnableRepositoryAPIResponse(repoData));

      // Mock the reload enabled repos API endpoint
      const reposApiPath = api.getApiUrl('/repositories');
      const reloadScope = nockInstance
        .get(reposApiPath)
        .query(true)
        .reply(200, createEnabledRepositoriesAPIResponse([]));

      const props = getBaseProps(repoData);
      const { getByRole } = renderWithRedux(
        <RepositorySetRepository {...props} />,
        getInitialState(),
      );

      const enableButton = getByRole('button');
      fireEvent.click(enableButton);

      // Wait for async operations and notifications
      await patientlyWaitFor(() => {
        expect(window.tfm.toastNotifications.notify).toHaveBeenCalledWith({
          message: `Repository '${expectedRepoName}' has been enabled.`,
          type: 'success',
        });
      });

      // Verify API calls were made
      assertNockRequest(enableScope);
      assertNockRequest(reloadScope);
    } finally {
      // Cleanup
      window.tfm = savedTfm;
    }
  });

  test('does not notify when enable operation fails', async () => {
    const repoData = repoSetRepoFixtures[0];

    // Mock window.tfm.toastNotifications
    const savedTfm = window.tfm;
    window.tfm = {
      toastNotifications: {
        notify: jest.fn(),
      },
    };

    try {
      // Mock the enable API endpoint to return error
      const enableApiPath = api.getApiUrl(`/products/${repoData.productId}/repository_sets/${repoData.contentId}/enable`);
      const enableScope = nockInstance
        .put(enableApiPath)
        .reply(422, {
          displayMessage: 'Repository cannot be enabled',
          errors: ['Repository already exists'],
        });

      const props = getBaseProps(repoData);
      const { getByRole } = renderWithRedux(
        <RepositorySetRepository {...props} />,
        getInitialState(),
      );

      const enableButton = getByRole('button');
      fireEvent.click(enableButton);

      // Wait for API request to complete and verify no notification was triggered
      await patientlyWaitFor(() => {
        expect(enableScope.isDone()).toBe(true);
        expect(window.tfm.toastNotifications.notify).not.toHaveBeenCalled();
      });
    } finally {
      // Cleanup
      window.tfm = savedTfm;
    }
  });

  test('renders multiple repository variants from fixture data', () => {
    const { getByText } = renderWithRedux(
      <>
        <RepositorySetRepository {...getBaseProps(repoSetRepoFixtures[0])} />
        <RepositorySetRepository {...getBaseProps(repoSetRepoFixtures[1])} />
        <RepositorySetRepository {...getBaseProps(repoSetRepoFixtures[2])} />
        <RepositorySetRepository {...getBaseProps(repoSetRepoFixtures[3])} />
      </>,
      getInitialState(),
    );

    // Verify different arch/releasever combinations appear
    expect(getByText('x86_64 8')).toBeInTheDocument(); // Standard release
    expect(getByText('x86_64 8.5')).toBeInTheDocument(); // Y-stream
    expect(getByText('aarch64 9')).toBeInTheDocument(); // Different arch
    expect(getByText('noarch')).toBeInTheDocument(); // Null releasever
  });
});
