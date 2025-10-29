import React from 'react';
import { Route } from 'react-router-dom';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest } from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import ManifestDetails from '../ManifestDetails';
import { DOCKER_TAG_DETAILS_KEY } from '../ManifestDetailsActions';
import manifestDetailsData from './manifestDetails.fixtures.json';
import manifestListData from './manifestList.fixtures.json';

const withManifestRoute = component => <Route path="/labs/container_images/:id([0-9]+)">{component}</Route>;

const renderOptions = (tagId = 2) => ({
  apiNamespace: `${DOCKER_TAG_DETAILS_KEY}_${tagId}`,
  routerParams: {
    initialEntries: [{ pathname: `/labs/container_images/${tagId}` }],
    initialIndex: 1,
  },
});

const manifestDetailsPath = id => api.getApiUrl(`/docker_tags/${id}`);

describe('ManifestDetails', () => {
  test('Can call API and display manifest details on load', async () => {
    const scope = nockInstance
      .get(manifestDetailsPath(2))
      .query(true)
      .reply(200, manifestDetailsData);

    const { getByText, getAllByText } = renderWithRedux(
      withManifestRoute(<ManifestDetails />),
      renderOptions(2),
    );

    await patientlyWaitFor(() => {
      expect(getByText('v1.0')).toBeInTheDocument();
    });

    // Check field labels
    expect(getByText('Name')).toBeInTheDocument();
    expect(getByText('Type')).toBeInTheDocument();
    expect(getByText('Repositories')).toBeInTheDocument();
    expect(getByText('Digest')).toBeInTheDocument();
    expect(getByText('Creation')).toBeInTheDocument();
    expect(getByText('Modified')).toBeInTheDocument();
    expect(getByText('Labels')).toBeInTheDocument();

    // Check values
    expect(getAllByText('v1.0')[0]).toBeInTheDocument();
    expect(getByText('ubi9-container')).toBeInTheDocument();

    // Check labels are displayed
    expect(getByText(/architecture/)).toBeInTheDocument();
    expect(getByText(/x86_64/)).toBeInTheDocument();

    assertNockRequest(scope);
  });

  test('Displays loading state initially', () => {
    nockInstance
      .get(manifestDetailsPath(2))
      .query(true)
      .delay(1000)
      .reply(200, manifestDetailsData);

    const { getByText } = renderWithRedux(
      withManifestRoute(<ManifestDetails />),
      renderOptions(2),
    );

    expect(getByText('Loading')).toBeInTheDocument();
  });

  test('Displays only library repositories', async () => {
    const scope = nockInstance
      .get(manifestDetailsPath(2))
      .query(true)
      .reply(200, manifestDetailsData);

    const { getByText, queryByText } = renderWithRedux(
      withManifestRoute(<ManifestDetails />),
      renderOptions(2),
    );

    await patientlyWaitFor(() => {
      expect(getByText('ubi9-container')).toBeInTheDocument();
    });

    // Should display Repositories label
    expect(getByText('Repositories')).toBeInTheDocument();

    // Should show library repository
    expect(getByText('ubi9-container')).toBeInTheDocument();

    // Should NOT show non-library repository
    expect(queryByText('ubi9-container-dev')).not.toBeInTheDocument();

    assertNockRequest(scope);
  });

  test('Repository links are clickable and have correct URLs', async () => {
    const scope = nockInstance
      .get(manifestDetailsPath(2))
      .query(true)
      .reply(200, manifestDetailsData);

    const { getByText } = renderWithRedux(
      withManifestRoute(<ManifestDetails />),
      renderOptions(2),
    );

    await patientlyWaitFor(() => {
      expect(getByText('ubi9-container')).toBeInTheDocument();
    });

    const repoLink = getByText('ubi9-container').closest('a');
    expect(repoLink).toBeInTheDocument();
    expect(repoLink).toHaveAttribute('href', '/products/5/repositories/10');
    expect(repoLink).toHaveAttribute('target', '_blank');
    expect(repoLink).toHaveAttribute('rel', 'noopener noreferrer');

    assertNockRequest(scope);
  });

  test('Displays "No labels" when labels are empty', async () => {
    const dataWithoutLabels = {
      ...manifestDetailsData,
      manifest: {
        ...manifestDetailsData.manifest,
        labels: {},
      },
    };

    const scope = nockInstance
      .get(manifestDetailsPath(2))
      .query(true)
      .reply(200, dataWithoutLabels);

    const { getByText } = renderWithRedux(
      withManifestRoute(<ManifestDetails />),
      renderOptions(2),
    );

    await patientlyWaitFor(() => {
      expect(getByText('No labels')).toBeInTheDocument();
    });

    assertNockRequest(scope);
  });

  test('Handles manifest list with child manifest query param', async () => {
    const scope = nockInstance
      .get(manifestDetailsPath(1))
      .query(true)
      .reply(200, manifestListData);

    const customRenderOptions = {
      apiNamespace: `${DOCKER_TAG_DETAILS_KEY}_1`,
      routerParams: {
        initialEntries: [{ pathname: '/labs/container_images/1', search: '?manifest=102' }],
        initialIndex: 1,
      },
    };

    const { getAllByText } = renderWithRedux(
      withManifestRoute(<ManifestDetails />),
      customRenderOptions,
    );

    await patientlyWaitFor(() => {
      // Should display child manifest digest in short form
      const elements = getAllByText(/sha256:1111aaaa2222/);
      expect(elements.length).toBeGreaterThan(0);
    });

    assertNockRequest(scope);
  });

  test('Breadcrumb navigates back to container images list', async () => {
    const scope = nockInstance
      .get(manifestDetailsPath(2))
      .query(true)
      .reply(200, manifestDetailsData);

    const { getByText } = renderWithRedux(
      withManifestRoute(<ManifestDetails />),
      renderOptions(2),
    );

    await patientlyWaitFor(() => {
      expect(getByText('Container images')).toBeInTheDocument();
    });

    const breadcrumbLink = getByText('Container images');
    expect(breadcrumbLink).toBeInTheDocument();

    assertNockRequest(scope);
  });

  test('Displays error message on 404 API error', async () => {
    const scope = nockInstance
      .get(manifestDetailsPath(999))
      .query(true)
      .reply(404, {
        error: { message: 'Not Found' },
      });

    const { getByText } = renderWithRedux(
      withManifestRoute(<ManifestDetails />),
      renderOptions(999),
    );

    await patientlyWaitFor(() => {
      expect(getByText('Not Found')).toBeInTheDocument();
    });

    assertNockRequest(scope);
  });

  test('Displays error message on 500 API error', async () => {
    const scope = nockInstance
      .get(manifestDetailsPath(2))
      .query(true)
      .reply(500, {
        error: { message: 'Internal Server Error' },
      });

    const { getByText } = renderWithRedux(
      withManifestRoute(<ManifestDetails />),
      renderOptions(2),
    );

    await patientlyWaitFor(() => {
      expect(getByText(/error/i)).toBeInTheDocument();
    });

    assertNockRequest(scope);
  });

  test('Handles manifest list with no child manifests', async () => {
    const dataWithEmptyManifests = {
      ...manifestDetailsData,
      manifest: {
        ...manifestDetailsData.manifest,
        manifest_type: 'list',
        manifests: [],
      },
    };

    const scope = nockInstance
      .get(manifestDetailsPath(2))
      .query(true)
      .reply(200, dataWithEmptyManifests);

    const { getByText } = renderWithRedux(
      withManifestRoute(<ManifestDetails />),
      renderOptions(2),
    );

    await patientlyWaitFor(() => {
      expect(getByText('v1.0')).toBeInTheDocument();
    });

    // Should still display basic manifest information
    expect(getByText('Name')).toBeInTheDocument();
    expect(getByText('Repositories')).toBeInTheDocument();
    expect(getByText('Digest')).toBeInTheDocument();

    assertNockRequest(scope);
  });

  test('Displays N/A when no library repositories are present', async () => {
    const dataWithoutLibraryRepos = {
      ...manifestDetailsData,
      repositories: [
        {
          id: 1,
          name: 'non-library-repo',
          library_instance: false,
        },
        {
          id: 2,
          name: 'another-non-library-repo',
          library_instance: false,
        },
      ],
    };

    const scope = nockInstance
      .get(manifestDetailsPath(2))
      .query(true)
      .reply(200, dataWithoutLibraryRepos);

    const { getByText, queryByText } = renderWithRedux(
      withManifestRoute(<ManifestDetails />),
      renderOptions(2),
    );

    await patientlyWaitFor(() => {
      expect(getByText('v1.0')).toBeInTheDocument();
    });

    // Repository field should show N/A when no library repositories
    expect(getByText('Repositories')).toBeInTheDocument();
    const repositoryValues = queryByText('N/A');
    expect(repositoryValues).toBeInTheDocument();

    // Non-library repos should not be displayed
    expect(queryByText('non-library-repo')).not.toBeInTheDocument();
    expect(queryByText('another-non-library-repo')).not.toBeInTheDocument();

    assertNockRequest(scope);
  });

  test('Displays correct manifest types', async () => {
    // Test bootable image
    const bootableData = {
      ...manifestDetailsData,
      manifest: {
        ...manifestDetailsData.manifest,
        manifest_type: 'image',
        is_bootable: true,
        is_flatpak: false,
      },
    };

    const bootableScope = nockInstance
      .get(manifestDetailsPath(3))
      .query(true)
      .reply(200, bootableData);

    const { getByText: getByTextBootable } = renderWithRedux(
      withManifestRoute(<ManifestDetails />),
      renderOptions(3),
    );

    await patientlyWaitFor(() => {
      expect(getByTextBootable('Bootable')).toBeInTheDocument();
    });

    assertNockRequest(bootableScope);

    // Test flatpak image
    const flatpakData = {
      ...manifestDetailsData,
      manifest: {
        ...manifestDetailsData.manifest,
        manifest_type: 'image',
        is_bootable: false,
        is_flatpak: true,
      },
    };

    const flatpakScope = nockInstance
      .get(manifestDetailsPath(4))
      .query(true)
      .reply(200, flatpakData);

    const { getByText: getByTextFlatpak } = renderWithRedux(
      withManifestRoute(<ManifestDetails />),
      renderOptions(4),
    );

    await patientlyWaitFor(() => {
      expect(getByTextFlatpak('Flatpak')).toBeInTheDocument();
    });

    assertNockRequest(flatpakScope);

    // Test manifest list
    const listData = {
      ...manifestDetailsData,
      manifest: {
        ...manifestDetailsData.manifest,
        manifest_type: 'list',
      },
    };

    const listScope = nockInstance
      .get(manifestDetailsPath(5))
      .query(true)
      .reply(200, listData);

    const { getByText: getByTextList } = renderWithRedux(
      withManifestRoute(<ManifestDetails />),
      renderOptions(5),
    );

    await patientlyWaitFor(() => {
      expect(getByTextList('List')).toBeInTheDocument();
    });

    assertNockRequest(listScope);
  });
});
