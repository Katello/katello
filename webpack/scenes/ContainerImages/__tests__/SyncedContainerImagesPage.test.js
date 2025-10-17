import React from 'react';
import { renderWithRedux, patientlyWaitFor, act } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockAutocomplete } from '../../../test-utils/nockWrapper';
import SyncedContainerImagesPage from '../SyncedContainerImagesPage';
import syncedImagesData from './syncedContainerImages.fixtures.json';

const syncedImagesUrl = '/katello/api/v2/docker_tags';
const autocompleteUrl = '/docker_tags/auto_complete_search';
const autocompleteQuery = {
  organization_id: '1',
  search: '',
};

const buildDockerTag = id => ({
  id,
  name: `tag-${id}`,
  manifest: {
    id: 100 + id,
    digest: `sha256:digest${id}digest${id}digest${id}digest${id}digest${id}digest${id}digest${id}`,
    manifest_type: 'image',
    is_bootable: false,
    is_flatpak: false,
  },
});

const createSyncedImages = (amount) => {
  const response = {
    total: amount,
    subtotal: amount,
    page: 1,
    per_page: 20,
    error: null,
    search: null,
    sort: {
      by: 'name',
      order: 'asc',
    },
    results: [],
  };

  [...Array(amount).keys()].forEach((_, i) => response.results.push(buildDockerTag(i + 1)));

  return response;
};

let latestTag;
let v10Tag;
let flatpakTag;
let childManifest1;
let childManifest2;

beforeEach(() => {
  const { results } = syncedImagesData;
  [latestTag, v10Tag, flatpakTag] = results;
  if (latestTag.manifest?.manifests) {
    [childManifest1, childManifest2] = latestTag.manifest.manifests;
  }
});

test('SyncedContainerImagesPage renders correctly', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(syncedImagesUrl)
    .query(true)
    .reply(200, syncedImagesData);

  const { queryByText } = renderWithRedux(<SyncedContainerImagesPage />);

  expect(queryByText(latestTag.name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(queryByText(latestTag.name)).toBeVisible();
    expect(queryByText(v10Tag.name)).toBeVisible();
    expect(queryByText(flatpakTag.name)).toBeVisible();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
  act(done);
});

test('Can expand manifest list and show child manifests', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(syncedImagesUrl)
    .query(true)
    .reply(200, syncedImagesData);

  const {
    queryByText, queryAllByRole,
  } = renderWithRedux(<SyncedContainerImagesPage />);

  expect(queryByText(latestTag.name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(queryByText(latestTag.name)).toBeVisible();

    // Find and click the expand button for the manifest list
    const expandButtons = queryAllByRole('button');
    const expandButton = expandButtons.find(btn =>
      btn.getAttribute('aria-labelledby')?.includes(`synced-containers-expander-${latestTag.id}`));

    if (expandButton) {
      expandButton.click();
    }
  });

  await patientlyWaitFor(() => {
    // Check that child manifest digests appear
    expect(queryByText(childManifest1.digest)).toBeVisible();
    expect(queryByText(childManifest2.digest)).toBeVisible();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
  act(done);
});

test('Displays correct manifest types', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(syncedImagesUrl)
    .query(true)
    .reply(200, syncedImagesData);

  const { queryByText, queryAllByText } = renderWithRedux(<SyncedContainerImagesPage />);

  await patientlyWaitFor(() => {
    // Check that manifest types are displayed correctly
    expect(queryByText('List')).toBeVisible(); // Capitalized 'list'
    expect(queryAllByText('Bootable').length).toBeGreaterThan(0); // For bootable images
    expect(queryByText('Flatpak')).toBeVisible(); // For flatpak images
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
  act(done);
});

test('Displays manifest digests correctly', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(syncedImagesUrl)
    .query(true)
    .reply(200, syncedImagesData);

  const { queryByText } = renderWithRedux(<SyncedContainerImagesPage />);

  await patientlyWaitFor(() => {
    expect(queryByText(latestTag.manifest.digest)).toBeVisible();
    expect(queryByText(v10Tag.manifest.digest)).toBeVisible();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
  act(done);
});

test('Child manifests remain hidden when not expanded', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(syncedImagesUrl)
    .query(true)
    .reply(200, syncedImagesData);

  const { queryByText } = renderWithRedux(<SyncedContainerImagesPage />);

  await patientlyWaitFor(() => {
    expect(queryByText(latestTag.name)).toBeVisible();
    // Child manifests should not be visible initially
    expect(queryByText(childManifest1.digest)?.closest('td')).not.toBeVisible();
    expect(queryByText(childManifest2.digest)?.closest('td')).not.toBeVisible();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
  act(done);
});

test('Can handle no container images being present', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const noResults = {
    total: 0,
    subtotal: 0,
    page: 1,
    per_page: 20,
    results: [],
  };
  const scope = nockInstance
    .get(syncedImagesUrl)
    .query(true)
    .reply(200, noResults);

  const { queryByText } = renderWithRedux(<SyncedContainerImagesPage />);

  expect(queryByText(latestTag.name)).toBeNull();
  await patientlyWaitFor(() => expect(queryByText('No Results')).toBeInTheDocument());

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

test('Displays loading state while fetching data', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(syncedImagesUrl)
    .query(true)
    .reply(200, syncedImagesData);

  const { queryByText } = renderWithRedux(<SyncedContainerImagesPage />);

  // Check for loading state
  expect(queryByText('Loading...')).toBeInTheDocument();

  await patientlyWaitFor(() => {
    expect(queryByText(latestTag.name)).toBeVisible();
    expect(queryByText('Loading...')).not.toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
  act(done);
});

test('Can handle pagination', async (done) => {
  const largeSyncedData = createSyncedImages(100);
  const { results } = largeSyncedData;
  const firstPage = { ...largeSyncedData, results: results.slice(0, 20) };
  const secondPage = { ...largeSyncedData, page: 2, results: results.slice(20, 40) };
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);

  // Match first page API request
  const firstPageScope = nockInstance
    .get(syncedImagesUrl)
    .query(true)
    .reply(200, firstPage);

  // Match second page API request
  const secondPageScope = nockInstance
    .get(syncedImagesUrl)
    .query(actualQueryObject => (parseInt(actualQueryObject.page, 10) === 2))
    .reply(200, secondPage);

  const { queryByText, getAllByLabelText } = renderWithRedux(<SyncedContainerImagesPage />);

  // Wait for first paginated page to load
  await patientlyWaitFor(() => {
    expect(queryByText(results[0].name)).toBeInTheDocument();
    expect(queryByText(results[19].name)).toBeInTheDocument();
    expect(queryByText(results[21].name)).not.toBeInTheDocument();
  });

  // Navigate to second page
  const [top, bottom] = getAllByLabelText('Go to next page');
  expect(top).toBeInTheDocument();
  expect(bottom).toBeInTheDocument();
  bottom.click();

  // Wait for second paginated page to load
  await patientlyWaitFor(() => {
    expect(queryByText(results[20].name)).toBeInTheDocument();
    expect(queryByText(results[39].name)).toBeInTheDocument();
    expect(queryByText(results[41].name)).not.toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(firstPageScope);
  assertNockRequest(secondPageScope, done);
  act(done);
});

test('Handles tags with manifest_schema1', async (done) => {
  const dataWithSchema1 = {
    ...syncedImagesData,
    results: [
      {
        id: 10,
        name: 'schema1-tag',
        manifest_schema1: {
          id: 110,
          digest: 'sha256:schema1digestschema1digestschema1digestschema1digestschema1digest',
          manifest_type: 'image',
          is_bootable: false,
          is_flatpak: false,
        },
      },
    ],
  };

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(syncedImagesUrl)
    .query(true)
    .reply(200, dataWithSchema1);

  const { queryByText } = renderWithRedux(<SyncedContainerImagesPage />);

  await patientlyWaitFor(() => {
    expect(queryByText('schema1-tag')).toBeVisible();
    expect(queryByText('sha256:schema1digestschema1digestschema1digestschema1digestschema1digest')).toBeVisible();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
  act(done);
});

test('Shows N/A for missing manifest data', async (done) => {
  const dataWithMissingManifest = {
    ...syncedImagesData,
    results: [
      {
        id: 11,
        name: 'no-manifest-tag',
      },
    ],
  };

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(syncedImagesUrl)
    .query(true)
    .reply(200, dataWithMissingManifest);

  const { queryByText, queryAllByText } = renderWithRedux(<SyncedContainerImagesPage />);

  await patientlyWaitFor(() => {
    expect(queryByText('no-manifest-tag')).toBeVisible();
    expect(queryAllByText('N/A').length).toBeGreaterThan(0);
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
  act(done);
});
