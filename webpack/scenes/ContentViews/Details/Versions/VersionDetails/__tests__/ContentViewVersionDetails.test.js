import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { Route } from 'react-router-dom';
import { head, last } from 'lodash';
import { nockInstance, assertNockRequest, mockSetting, mockAutocomplete } from '../../../../../../test-utils/nockWrapper';
import api from '../../../../../../services/api';
import { cvVersionDetailsKey } from '../../../../ContentViewsConstants';
import ContentViewVersionDetails from '../ContentViewVersionDetails';
import { AUTOSEARCH_DELAY, AUTOSEARCH_WHILE_TYPING } from '../../../../../Settings/SettingsConstants';


const ContentViewVersionDetailsData = require('./ContentViewVersionDetails.fixtures.json');
const ContentViewVersionDetailsCounts = require('./ContentViewVersionDetailsCounts.fixtures.json');

// This changes the api count value so that only the specified tab will show.
const getTabSpecificData = key => ({
  ...ContentViewVersionDetailsData,
  [key]: ContentViewVersionDetailsCounts[key],
});

// Tab Fixtures
const ContentViewVersionsComponentData = require('./ContentViewVersionComponent.fixtures.json');
const ContentViewVersionsRepositoriesData = require('./ContentViewVersionRepositories.fixtures.json');
const ContentViewVersionRpmPackagesData = require('./ContentViewVersionRpmPackages.fixtures.json');
const ContentViewVersionRpmPackageGroupsData = require('./ContentViewVersionRpmPackageGroups.fixtures.json');
const ContentViewVersionFilesData = require('./ContentViewVersionFiles.fixtures.json');
const ContentViewVersionErrataData = require('./ContentViewVersionErrata.fixtures.json');
const ContentViewVersionModuleStreamsData = require('./ContentViewVersionModuleStreams.fixtures.json');
const ContentViewVersionDebPackagesData = require('./ContentViewVersionDebPackages.fixtures.json');
const ContentViewVersionAnsibleCollectionsData = require('./ContentViewVersionAnsibleCollections.fixtures.json');
const ContentViewVersionDockerTagsData = require('./ContentViewVersionDockerTags.fixtures.json');

const withCVRoute = component => <Route path="/versions/:versionId([0-9]+)">{component}</Route>;

const cvVersions = api.getApiUrl('/content_view_versions/73');

const renderOptions = {
  apiNamespace: cvVersionDetailsKey(3, 73),
  routerParams: {
    initialEntries: [{ pathname: '/versions/73' }],
    initialIndex: 1,
  },
};

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
    withCVRoute(<ContentViewVersionDetails cvId={3} />),
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
    name: 'Docker Tags',
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

    const autocompleteScope = mockAutocomplete(nockInstance, autoCompleteUrl);
    const searchDelayScope = mockSetting(nockInstance, AUTOSEARCH_DELAY, 500);
    const autoSearchScope = mockSetting(nockInstance, AUTOSEARCH_WHILE_TYPING, true);

    const scope = nockInstance
      .get(cvVersions)
      .query(true)
      .reply(200, getTabSpecificData(countKey));

    const tabScope = nockInstance
      .get(dataUrl)
      .query(true)
      .reply(200, data);

    const { getByText, queryByText } = renderWithRedux(
      withCVRoute(<ContentViewVersionDetails cvId={3} />),
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
    assertNockRequest(searchDelayScope);
    assertNockRequest(autoSearchScope);
    assertNockRequest(tabScope);
    assertNockRequest(scope, done);
  }));
