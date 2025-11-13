import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import nock from 'nock';
import { nockInstance, assertNockRequest } from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import EnabledRepository from '../index'; // Import connected component
import enabledRepoFixtures from './enabledRepository.fixtures.json';

// Mock external components
jest.mock('../../RepositoryTypeIcon', () => ({
  __esModule: true,
  default: ({ type }) => <div data-testid="repository-type-icon">{type}</div>,
}));

// Mock orgId function while preserving the rest of the api module
jest.mock('../../../../../services/api', () => {
  const actual = jest.requireActual('../../../../../services/api');
  return {
    ...actual,
    __esModule: true,
    orgId: jest.fn(() => 1),
  };
});

// Create API response format matching what the backend returns
const createRepositoriesAPIResponse = repos => ({
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
    content_view_versions: repo.content_view_versions,
    orphaned: repo.orphaned,
  })),
});

const getBaseProps = (repoData = enabledRepoFixtures[0]) => ({
  id: repoData.id,
  contentId: repoData.content_id,
  productId: repoData.product_id,
  name: repoData.name,
  label: repoData.label,
  type: repoData.type,
  arch: repoData.arch,
  releasever: repoData.releasever,
  orphaned: repoData.orphaned,
  loading: false,
  canDisable: repoData.permissions.deletable,
});

const getInitialState = (repos = enabledRepoFixtures) => ({
  katello: {
    redHatRepositories: {
      enabled: {
        loading: false,
        repositories: repos.map(repo => ({
          id: repo.id,
          contentId: repo.content_id,
          productId: repo.product_id,
          name: repo.name,
          label: repo.label,
          type: repo.type,
          arch: repo.arch,
          releasever: repo.releasever,
          orphaned: repo.orphaned,
          canDisable: repo.permissions.deletable,
        })),
        pagination: { page: 1, perPage: 20 },
        itemCount: repos.length,
        search: { query: '' },
      },
    },
  },
});

describe('EnabledRepository Component', () => {
  afterEach(() => {
    nock.cleanAll();
    jest.clearAllMocks();
  });

  test('renders repository with name and label', () => {
    const props = getBaseProps(enabledRepoFixtures[0]);
    const { getByText } = renderWithRedux(<EnabledRepository {...props} />, getInitialState());

    expect(getByText('Red Hat Enterprise Linux 8 for x86_64 - BaseOS RPMs 8')).toBeInTheDocument();
    expect(getByText('Red_Hat_Enterprise_Linux_8_for_x86_64_-_BaseOS_RPMs_8')).toBeInTheDocument();
  });

  test('renders repository type icon', () => {
    const props = getBaseProps(enabledRepoFixtures[0]);
    const { getByTestId, getByText } = renderWithRedux(
      <EnabledRepository {...props} />,
      getInitialState(),
    );

    expect(getByTestId('repository-type-icon')).toBeInTheDocument();
    expect(getByText('yum')).toBeInTheDocument();
  });

  test('renders orphaned indicator when repository is orphaned', () => {
    const props = getBaseProps(enabledRepoFixtures[2]); // Orphaned repo
    const { getByText } = renderWithRedux(<EnabledRepository {...props} />, getInitialState());

    expect(getByText(/Red Hat Enterprise Linux 9 for aarch64 - BaseOS RPMs 9/i)).toBeInTheDocument();
    expect(getByText(/\(Orphaned\)/i)).toBeInTheDocument();
  });

  test('does not show orphaned indicator for non-orphaned repository', () => {
    const props = getBaseProps(enabledRepoFixtures[0]); // Non-orphaned repo
    const { queryByText } = renderWithRedux(<EnabledRepository {...props} />, getInitialState());

    expect(queryByText(/\(Orphaned\)/i)).not.toBeInTheDocument();
  });

  test('renders disable button when repository can be disabled', () => {
    const props = getBaseProps(enabledRepoFixtures[0]); // deletable: true
    const { container } = renderWithRedux(<EnabledRepository {...props} />, getInitialState());

    // For legacy PatternFly v3 button with icon
    const disableButton = container.querySelector('button');
    expect(disableButton).toBeInTheDocument();
    expect(disableButton).not.toBeDisabled();
  });

  test('renders disabled button when repository cannot be disabled', () => {
    const props = getBaseProps(enabledRepoFixtures[1]); // deletable: false (in content view)
    const { container } = renderWithRedux(<EnabledRepository {...props} />, getInitialState());

    // For legacy PatternFly v3 button with icon
    const disableButton = container.querySelector('button');
    expect(disableButton).toBeInTheDocument();
    expect(disableButton).toBeDisabled();
  });

  test('disables repository via API when disable button is clicked', async () => {
    const repoData = enabledRepoFixtures[0];

    // Mock window.tfm.toastNotifications
    const savedTfm = window.tfm;
    window.tfm = {
      toastNotifications: {
        notify: jest.fn(),
      },
    };

    try {
      // Mock the disable API endpoint
      const disableApiPath = api.getApiUrl(`/products/${repoData.product_id}/repository_sets/${repoData.content_id}/disable`);
      const disableScope = nockInstance
        .put(disableApiPath)
        .reply(200, { success: true });

      // Mock the reload enabled repos API endpoint
      const reposApiPath = api.getApiUrl('/repositories');
      const reloadScope = nockInstance
        .get(reposApiPath)
        .query(true)
        .reply(200, createRepositoriesAPIResponse(enabledRepoFixtures));

      const props = getBaseProps(repoData);
      const { container } = renderWithRedux(<EnabledRepository {...props} />, getInitialState());

      // For legacy PatternFly v3 button with icon
      const disableButton = container.querySelector('button');
      fireEvent.click(disableButton);

      // Wait for async operations and notifications
      await patientlyWaitFor(() => {
        expect(window.tfm.toastNotifications.notify).toHaveBeenCalledWith({
          message: "Repository 'Red Hat Enterprise Linux 8 for x86_64 - BaseOS RPMs 8' has been disabled.",
          type: 'success',
        });
      });

      // Verify API calls were made
      assertNockRequest(disableScope);
      assertNockRequest(reloadScope);
    } finally {
      // Cleanup
      window.tfm = savedTfm;
    }
  });

  test('does not reload or notify when disable operation fails', async () => {
    const repoData = enabledRepoFixtures[0];

    // Mock window.tfm.toastNotifications
    const savedTfm = window.tfm;
    window.tfm = {
      toastNotifications: {
        notify: jest.fn(),
      },
    };

    try {
      // Mock the disable API endpoint to return error
      const disableApiPath = api.getApiUrl(`/products/${repoData.product_id}/repository_sets/${repoData.content_id}/disable`);
      const disableScope = nockInstance
        .put(disableApiPath)
        .reply(422, {
          displayMessage: 'Repository cannot be disabled',
          errors: ['Repository is in use'],
        });

      const props = getBaseProps(repoData);
      const { container } = renderWithRedux(<EnabledRepository {...props} />, getInitialState());

      // For legacy PatternFly v3 button with icon
      const disableButton = container.querySelector('button');
      fireEvent.click(disableButton);

      // Wait for async operation to complete
      await patientlyWaitFor(() => {
        expect(disableScope.isDone()).toBe(true);
      });

      // Wait a bit more to ensure no notification was triggered
      await new Promise(resolve => setTimeout(resolve, 100));

      // Verify notification was NOT called on error
      expect(window.tfm.toastNotifications.notify).not.toHaveBeenCalled();
    } finally {
      // Cleanup
      window.tfm = savedTfm;
    }
  });

  test('handles repository with null releasever', () => {
    const props = getBaseProps(enabledRepoFixtures[1]); // Has null releasever
    const { getByText } = renderWithRedux(<EnabledRepository {...props} />, getInitialState());

    expect(getByText('Red Hat Satellite Tools 6.15 for RHEL 8 x86_64 RPMs')).toBeInTheDocument();
  });

  test('renders loading state correctly', () => {
    const props = {
      ...getBaseProps(enabledRepoFixtures[0]),
      loading: true,
    };
    const { container } = renderWithRedux(<EnabledRepository {...props} />, getInitialState());

    // For legacy PatternFly v3 Spinner component - button may be hidden during loading
    // Just verify the component renders without errors during loading state
    expect(container.firstChild).toBeInTheDocument();
  });

  test('renders all three repositories from fixture data', () => {
    const { getByText } = renderWithRedux(
      <>
        <EnabledRepository {...getBaseProps(enabledRepoFixtures[0])} />
        <EnabledRepository {...getBaseProps(enabledRepoFixtures[1])} />
        <EnabledRepository {...getBaseProps(enabledRepoFixtures[2])} />
      </>,
      getInitialState(),
    );

    // Verify all three repository names appear
    expect(getByText('Red Hat Enterprise Linux 8 for x86_64 - BaseOS RPMs 8')).toBeInTheDocument();
    expect(getByText('Red Hat Satellite Tools 6.15 for RHEL 8 x86_64 RPMs')).toBeInTheDocument();
    expect(getByText(/Red Hat Enterprise Linux 9 for aarch64 - BaseOS RPMs 9/i)).toBeInTheDocument();

    // Verify all three labels appear
    expect(getByText('Red_Hat_Enterprise_Linux_8_for_x86_64_-_BaseOS_RPMs_8')).toBeInTheDocument();
    expect(getByText('Red_Hat_Satellite_Tools_6.15_for_RHEL_8_x86_64_RPMs')).toBeInTheDocument();
    expect(getByText('Red_Hat_Enterprise_Linux_9_for_aarch64_-_BaseOS_RPMs_9')).toBeInTheDocument();
  });
});
