import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { Route } from 'react-router-dom';
import { head, last } from 'lodash';
import { nockInstance, assertNockRequest, mockAutocomplete } from '../../../../../../test-utils/nockWrapper';
import api from '../../../../../../services/api';
import { cvVersionDetailsKey } from '../../../../ContentViewsConstants';
import ContentViewVersionDetails from '../ContentViewVersionDetails';
import ContentViewVersionDetailsData from './ContentViewVersionDetails.fixtures.json';
import ContentViewVersionDetailsCounts from './ContentViewVersionDetailsCounts.fixtures.json';
import cvDetailData from '../../../../__tests__/mockDetails.fixtures.json';
import ContentViewVersionsComponentData from './ContentViewVersionComponent.fixtures.json';
import ContentViewVersionsRepositoriesData from './ContentViewVersionRepositories.fixtures.json';
import ContentViewVersionRpmPackagesData from './ContentViewVersionRpmPackages.fixtures.json';
import ContentViewVersionRpmPackageGroupsData from './ContentViewVersionRpmPackageGroups.fixtures.json';
import ContentViewVersionFilesData from './ContentViewVersionFiles.fixtures.json';
import ContentViewVersionErrataData from './ContentViewVersionErrata.fixtures.json';
import ContentViewVersionModuleStreamsData from './ContentViewVersionModuleStreams.fixtures.json';
import ContentViewVersionDebPackagesData from './ContentViewVersionDebPackages.fixtures.json';
import ContentViewVersionAnsibleCollectionsData from './ContentViewVersionAnsibleCollections.fixtures.json';
import ContentViewVersionDockerTagsData from './ContentViewVersionDockerTags.fixtures.json';
import environmentPathsData from '../../Delete/__tests__/versionRemoveEnvPaths.fixtures';

// This changes the api count value so that only the specified tab will show.
const getTabSpecificData = key => ({
  ...ContentViewVersionDetailsData,
  [key]: ContentViewVersionDetailsCounts[key],
});
let envScope;
const environmentPathsPath = api.getApiUrl('/organizations/1/environments/paths');

const withCVRoute = component => <Route path="/versions/:versionId([0-9]+)">{component}</Route>;

const cvVersions = api.getApiUrl('/content_view_versions/73');

const renderOptions = {
  apiNamespace: cvVersionDetailsKey(3, 73),
  routerParams: {
    initialEntries: [{ pathname: '/versions/73' }],
    initialIndex: 1,
  },
};

const autocompleteQuery = name => ((name === 'Repositories') ? {
  archived: true,
  organization_id: 1,
  content_view_version_id: 73,
  search: '',
} : {
  organization_id: 1,
  content_view_version_id: 73,
  search: '',
});

const queryParams = name => ((name === 'Repositories') ? {
  archived: true,
  content_view_version_id: 73,
  per_page: 20,
  page: 1,
} : {
  content_view_version_id: 73,
  per_page: 20,
  page: 1,
});

beforeEach(() => {
  envScope = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);
});

afterEach(() => {
  assertNockRequest(envScope);
});
// This is written separately, as the autocomplete/search scopes are not needed.
test('Can show versions details - Components Tab', async (done) => {
  const { version } = ContentViewVersionDetailsData;
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, getTabSpecificData('component_view_count'));

  const componentScope = nockInstance
    .get(api.getApiUrl('/content_view_versions'))
    .query(true)
    .reply(200, ContentViewVersionsComponentData);

  const { getByText, queryByText } = renderWithRedux(
    withCVRoute(<ContentViewVersionDetails cvId={3} details={cvDetailData} />),
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(`Version ${version}`)).toBeNull();
  // Assert that the CV version is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(getByText(`Version ${version}`)).toBeTruthy();
  });

  await patientlyWaitFor(() => {
    expect(queryByText('Components')).toBeTruthy();
    expect(queryByText(head(ContentViewVersionsComponentData.results)
      .content_view.name)).toBeTruthy();
    expect(queryByText(last(ContentViewVersionsComponentData.results)
      .content_view.name)).toBeTruthy();
  });

  assertNockRequest(scope);
  assertNockRequest(scope);
  assertNockRequest(componentScope, done);
});

const testConfig = [
  {
    name: 'Repositories',
    countKey: 'repositories',
    autoCompleteUrl: '/repositories/auto_complete_search',
    dataUrl: api.getApiUrl('/repositories'),
    data: ContentViewVersionsRepositoriesData,
    textQuery: [
      head(ContentViewVersionsRepositoriesData.results).name,
      last(ContentViewVersionsRepositoriesData.results).name],
  },
  {
    name: 'RPM Packages',
    countKey: 'rpm_count',
    autoCompleteUrl: '/packages/auto_complete_search',
    dataUrl: api.getApiUrl('/packages'),
    data: ContentViewVersionRpmPackagesData,
    textQuery: [
      head(ContentViewVersionRpmPackagesData.results).nvra,
      last(ContentViewVersionRpmPackagesData.results).nvra],
  },
  {
    name: 'RPM Package Groups',
    countKey: 'package_group_count',
    autoCompleteUrl: '/package_groups/auto_complete_search',
    dataUrl: api.getApiUrl('/package_groups'),
    data: ContentViewVersionRpmPackageGroupsData,
    textQuery: [
      head(ContentViewVersionRpmPackageGroupsData.results).name,
      last(ContentViewVersionRpmPackageGroupsData.results).name],
  },
  {
    name: 'Files',
    countKey: 'file_count',
    autoCompleteUrl: '/files/auto_complete_search',
    dataUrl: api.getApiUrl('/files'),
    data: ContentViewVersionFilesData,
    textQuery: [
      head(ContentViewVersionFilesData.results).name,
      last(ContentViewVersionFilesData.results).name],
  },
  {
    name: 'Errata',
    countKey: 'erratum_count',
    autoCompleteUrl: '/errata/auto_complete_search',
    dataUrl: api.getApiUrl('/errata'),
    data: ContentViewVersionErrataData,
    textQuery: [
      head(ContentViewVersionErrataData.results).errata_id,
      last(ContentViewVersionErrataData.results).errata_id],
  },
  {
    name: 'Module Streams',
    countKey: 'module_stream_count',
    autoCompleteUrl: '/module_streams/auto_complete_search',
    dataUrl: api.getApiUrl('/module_streams'),
    data: ContentViewVersionModuleStreamsData,
    textQuery: [
      head(ContentViewVersionModuleStreamsData.results).version,
      last(ContentViewVersionModuleStreamsData.results).version],
  },
  {
    name: 'Deb Packages',
    countKey: 'deb_count',
    autoCompleteUrl: '/debs/auto_complete_search',
    dataUrl: api.getApiUrl('/debs'),
    data: ContentViewVersionDebPackagesData,
    textQuery: [
      head(ContentViewVersionDebPackagesData.results).name,
      last(ContentViewVersionDebPackagesData.results).name],
  },
  {

    name: 'Ansible Collections',
    countKey: 'ansible_collection_count',
    autoCompleteUrl: '/ansible_collections/auto_complete_search',
    dataUrl: api.getApiUrl('/ansible_collections'),
    data: ContentViewVersionAnsibleCollectionsData,
    textQuery: [
      head(ContentViewVersionAnsibleCollectionsData.results).checksum,
      last(ContentViewVersionAnsibleCollectionsData.results).checksum],
  },
  {
    name: 'Container tags',
    countKey: 'docker_tag_count',
    autoCompleteUrl: '/docker_tags/auto_complete_search',
    dataUrl: api.getApiUrl('/docker_tags'),
    data: ContentViewVersionDockerTagsData,
    textQuery: [
      head(ContentViewVersionDockerTagsData.results).name,
      last(ContentViewVersionDockerTagsData.results).name],
  },
];

testConfig.forEach(({
  name,
  autoCompleteUrl,
  countKey,
  dataUrl,
  data,
  textQuery,
}) =>
  test(`Can show versions details - ${name} Tab`, async (done) => {
    const { version } = ContentViewVersionDetailsData;

    const autocompleteScope = mockAutocomplete(
      nockInstance,
      autoCompleteUrl,
      autocompleteQuery(name),
    );

    const scope = nockInstance
      .get(cvVersions)
      .query(true)
      .reply(200, getTabSpecificData(countKey));

    const tabScope = nockInstance
      .get(dataUrl)
      .query(queryParams(name))
      .reply(200, data);

    const { getByText, queryByText } = renderWithRedux(
      withCVRoute(<ContentViewVersionDetails cvId={3} details={cvDetailData} />),
      renderOptions,
    );

    // Nothing will show at first, page is loading
    expect(queryByText(`Version ${version}`)).toBeNull();

    // Assert that the CV version is now showing on the screen, but wait for it to appear.
    await patientlyWaitFor(() => {
      expect(getByText(`Version ${version}`)).toBeTruthy();
    });

    // Ensure that tab exists on the screen
    await patientlyWaitFor(() => {
      expect(queryByText(name)).toBeTruthy();
      // This queries for data specific to the table to ensure it's present:
      textQuery.forEach(query => expect(queryByText(query)).toBeTruthy());
    });

    assertNockRequest(autocompleteScope);
    assertNockRequest(scope);
    assertNockRequest(tabScope);
    assertNockRequest(scope, done);
  }));

test('Can change repository selector', async (done) => {
  const {
    countKey,
    autoCompleteUrl,
    dataUrl,
    data,
  } = testConfig[1]; // RPM Packages

  const { version } = ContentViewVersionDetailsData;
  const autocompleteScope = mockAutocomplete(nockInstance, autoCompleteUrl, autocompleteQuery);

  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, {
      ...getTabSpecificData(countKey),
      repositories: ContentViewVersionDetailsCounts.repositories,
    });

  const tabScope = nockInstance
    .get(dataUrl)
    .query(true)
    .times(2) // Expect two calls, the initial one, and the one made on selection
    .reply(200, data);

  const { getByText, queryByText } = renderWithRedux(
    withCVRoute(<ContentViewVersionDetails cvId={3} details={cvDetailData} />),
    {
      ...renderOptions,
      routerParams: {
        initialEntries: [{ pathname: '/versions/73/rpmPackages' }],
        initialIndex: 1,
      },
    },
  );

  // Nothing will show at first, page is loading
  expect(queryByText(`Version ${version}`)).toBeNull();

  // Assert that the CV version is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(getByText(`Version ${version}`)).toBeTruthy();
  });

  // Click the All Repositories Drop Down
  await patientlyWaitFor(() => {
    expect(getByText('All Repositories')).toBeTruthy();
    getByText('All Repositories').click();
  });

  // Select a repo to filter by
  await patientlyWaitFor(() => {
    getByText('Zoo Repo Uno');
    getByText('Zoo Repo Uno').click();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(tabScope);
  assertNockRequest(scope, done);
});
