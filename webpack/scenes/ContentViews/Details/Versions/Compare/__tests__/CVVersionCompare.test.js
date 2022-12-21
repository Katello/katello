import React from 'react';
import { act, renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { Route } from 'react-router-dom';
import { head, last } from 'lodash';
import { nockInstance, assertNockRequest, mockAutocomplete } from '../../../../../../test-utils/nockWrapper';
import api from '../../../../../../services/api';

import ContentViewVersions from '../../ContentViewVersions';
import cvVersionsData from './contentViewVersions.fixtures.json';
import cvDetailsData from './contentViewDetails.fixtures.json';
import environmentPathsData from '../../../../Publish/__tests__/environmentPaths.fixtures.json';
import CVVersionCompare from '../CVVersionCompare';
import cvCompareRepositoriesData from './cvCompareRepositories.fixtures.json';
import cvVersionRPMPackagesCompareAllContentData from './RPMPackagesCompareAllContentData.fixtures.json';
import cvVersionErrataCompareAllContentData from './ErrataCompareAllContentData.fixtures.json';
import cvVersionPackageGroupsCompareAllContentData from './PackageGroupsCompareAllContentData.fixtures.json';
import cvVersionFilesCompareAllContentData from './FilesCompareAllContentData.fixtures.json';
import cvVersionModuleStreamsCompareAllContentData from './ModuleStreamsCompareAllContentData.fixtures.json';
import cvVersionDebPackagesCompareAllContentData from './DebPackagesCompareAllContentData.fixtures.json';
import cvVersionContainerTagsCompareAllContentData from './ContainerTagsCompareAllContentData.fixtures.json';
import cvVersionPythonPackagesCompareAllContentData from './PythonPackagesCompareAllContentData.fixtures.json';
import cvVersionAnsibleCollectionsCompareAllContentData from './AnsibleCollectionsCompareAllContentData.fixtures.json';
import cvVersionRPMPackagesCompareThreeContentTypesData from './RPMPackagesCompareThreeContentTypesData.fixtures.json';
import cvVersionFilesCompareThreeContentTypesData from './FilesCompareThreeContentTypesData.fixtures.json';
import cvVersionErrataCompareThreeContentTypesData from './ErrataCompareThreeContentTypesData.fixtures.json';
import versionOneDetailsData from './contentViewVersionOneDetials.fixtures.json';
import versionTwoDetailsData from './contentViewVersionTwoDetails.fixtures.json';
import versionThreeDetailsData from './contentViewVersionThreeDetails.fixtures.json';
import emptyStateVersionOneData from './emptyStateCVVersionOneDetails.fixtures.json';
import empptyStateVersionTwoData from './emptyStateCVVersionTwoDetails.fixtures.json';
import cvVersionEmptyContent from './CVVersionEmptyContentCompareData.fixtures.json';

const cvVersions = api.getApiUrl('/content_view_versions');
const cvDetails = api.getApiUrl('/content_views/4');
const versionDetails = versionId => api.getApiUrl(`/content_view_versions/${versionId}`);
const autocompleteUrl = '/content_view_versions/auto_complete_search';
const withCVRoute = component => <Route path="/content_views/:id">{component}</Route>;
const environmentPathsPath = api.getApiUrl('/organizations/1/environments/paths');
const sortedRpmPackagesPath = api.getApiUrl('/packages/compare?content_view_version_ids[]=15&content_view_version_ids[]=17&restrict_comparison=all&sort_by=nvra&sort_order=desc&per_page=20&page=1');
const renderOptions = {
  initialState: {
    API: {
      CONTENT_VIEW_VERSION_DETAILS_51_21: {
        status: 'RESOLVED',
      },
      CONTENT_VIEW_VERSION_DETAILS_55_21: {
        status: 'RESOLVED',
      },
    },
  },
  routerParams: {
    initialEntries: [{ pathname: '/content_views/4' }],
    initialIndex: 1,
  },

};

let envScope;

const versionIdsAllContentTypes = {
  versionOneId: '15',
  versionTwoId: '17',
};

const versionIdsThreeContentTypes = {
  versionOneId: '14',
  versionTwoId: '15',
};

const versionLabelsAllContentTypes = {
  versionOneLabel: '4.0',
  versionTwoLabel: '6.0',
};

const versionLabelsThreeContentTypes = {
  versionOneLabel: '3.0',
  versionTwoLabel: '4.0',
};
beforeEach(() => {
  envScope = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);
});

afterEach(() => {
  assertNockRequest(envScope);
});

const testConfigAllContentTypes = [
  {
    name: 'Repositories',
    autoCompleteUrl: '/repositories/auto_complete_search',
    dataUrl: api.getApiUrl('/repositories/compare'),
    data: cvCompareRepositoriesData,
    textQuery: [
      head(cvCompareRepositoriesData.results).name,
      last(cvCompareRepositoriesData.results).name],
  },
  {
    name: 'RPM packages',
    countKey: 'rpm_count',
    autoCompleteUrl: '/packages/auto_complete_search',
    dataUrl: api.getApiUrl('/packages/compare'),
    data: cvVersionRPMPackagesCompareAllContentData,
    textQuery: [
      head(cvVersionRPMPackagesCompareAllContentData.results).nvrea,
      last(cvVersionRPMPackagesCompareAllContentData.results).nvrea],
  },
  {
    name: 'RPM package groups',
    countKey: 'package_group_count',
    autoCompleteUrl: '/package_groups/auto_complete_search',
    dataUrl: api.getApiUrl('/package_groups/compare'),
    data: cvVersionPackageGroupsCompareAllContentData,
    textQuery: [
      head(cvVersionPackageGroupsCompareAllContentData.results).name,
      last(cvVersionPackageGroupsCompareAllContentData.results).name],
  },
  {
    name: 'Files',
    countKey: 'file_count',
    autoCompleteUrl: '/files/auto_complete_search',
    dataUrl: api.getApiUrl('/files/compare'),
    data: cvVersionFilesCompareAllContentData,
    textQuery: [
      head(cvVersionFilesCompareAllContentData.results).name,
      last(cvVersionFilesCompareAllContentData.results).name],
  },
  {
    name: 'Errata',
    countKey: 'erratum_count',
    autoCompleteUrl: '/errata/auto_complete_search',
    dataUrl: api.getApiUrl('/errata/compare'),
    data: cvVersionErrataCompareAllContentData,
    textQuery: [
      head(cvVersionErrataCompareAllContentData.results).name,
      last(cvVersionErrataCompareAllContentData.results).name],
  },
  {
    name: 'Module streams',
    countKey: 'module_stream_count',
    autoCompleteUrl: '/module_streams/auto_complete_search',
    dataUrl: api.getApiUrl('/module_streams/compare'),
    data: cvVersionModuleStreamsCompareAllContentData,
    textQuery: [
      head(cvVersionModuleStreamsCompareAllContentData.results).name,
      last(cvVersionModuleStreamsCompareAllContentData.results).name],
  },
  {
    name: 'Deb packages',
    countKey: 'deb_count',
    autoCompleteUrl: '/debs/auto_complete_search',
    dataUrl: api.getApiUrl('/debs/compare'),
    data: cvVersionDebPackagesCompareAllContentData,
    textQuery: [
      head(cvVersionDebPackagesCompareAllContentData.results).name,
      last(cvVersionDebPackagesCompareAllContentData.results).name],
  },
  {
    name: 'Container tags',
    countKey: 'docker_tag_count',
    autoCompleteUrl: '/docker_tags/auto_complete_search',
    dataUrl: api.getApiUrl('/docker_tags/compare'),
    data: cvVersionContainerTagsCompareAllContentData,
    textQuery: [
      head(cvVersionContainerTagsCompareAllContentData.results).name,
      last(cvVersionContainerTagsCompareAllContentData.results).name],
  },
  {
    name: 'Python packages',
    countKey: 'python_package_count',
    autoCompleteUrl: '/python_packages/auto_complete_search',
    dataUrl: api.getApiUrl('/python_packages/compare'),
    data: cvVersionPythonPackagesCompareAllContentData,
    textQuery: [
      head(cvVersionPythonPackagesCompareAllContentData.results).name,
      last(cvVersionPythonPackagesCompareAllContentData.results).name],
  },
  {
    name: 'Ansible collections',
    countKey: 'ansible_collection_count',
    autoCompleteUrl: '/ansible_collections/auto_complete_search',
    dataUrl: api.getApiUrl('/ansible_collections/compare'),
    data: cvVersionAnsibleCollectionsCompareAllContentData,
    textQuery: [
      head(cvVersionAnsibleCollectionsCompareAllContentData.results).name,
      last(cvVersionAnsibleCollectionsCompareAllContentData.results).name],
  },
];

const testConfigThreeContentTypes = [
  {
    name: 'Repositories',
    autoCompleteUrl: '/repositories/auto_complete_search',
    dataUrl: api.getApiUrl('/repositories/compare'),
    data: cvCompareRepositoriesData,
    textQuery: [
      head(cvCompareRepositoriesData.results).name,
      last(cvCompareRepositoriesData.results).name],
  },
  {
    name: 'RPM packages',
    countKey: 'rpm_count',
    autoCompleteUrl: '/packages/auto_complete_search',
    dataUrl: api.getApiUrl('/packages/compare'),
    data: cvVersionRPMPackagesCompareThreeContentTypesData,
    textQuery: [
      head(cvVersionRPMPackagesCompareThreeContentTypesData.results).nvrea,
      last(cvVersionRPMPackagesCompareThreeContentTypesData.results).nvrea],
  },
  {
    name: 'Errata',
    countKey: 'erratum_count',
    autoCompleteUrl: '/errata/auto_complete_search',
    dataUrl: api.getApiUrl('/errata/compare'),
    data: cvVersionErrataCompareThreeContentTypesData,
    textQuery: [
      head(cvVersionErrataCompareThreeContentTypesData.results).name,
      last(cvVersionErrataCompareThreeContentTypesData.results).name],
  },
  {
    name: 'Files',
    countKey: 'file_count',
    autoCompleteUrl: '/files/auto_complete_search',
    dataUrl: api.getApiUrl('/files/compare'),
    data: cvVersionFilesCompareThreeContentTypesData,
    textQuery: [
      head(cvVersionFilesCompareThreeContentTypesData.results).name,
      last(cvVersionFilesCompareThreeContentTypesData.results).name],
  },
];
const emptyContentViewByText = contentType => `No matching ${contentType} found.`;

const testConfigViewByDifferent = [
  {
    name: 'Repositories',
    autoCompleteUrl: '/repositories/auto_complete_search',
    dataUrl: api.getApiUrl('/repositories/compare'),
    data: cvVersionEmptyContent,
    textQuery: emptyContentViewByText('Repositories'),
  },
  {
    name: 'RPM packages',
    countKey: 'rpm_count',
    autoCompleteUrl: '/packages/auto_complete_search',
    dataUrl: api.getApiUrl('/packages/compare'),
    data: cvVersionEmptyContent,
    textQuery: emptyContentViewByText('RPM packages'),
  },
  {
    name: 'Errata',
    countKey: 'erratum_count',
    autoCompleteUrl: '/errata/auto_complete_search',
    dataUrl: api.getApiUrl('/errata/compare'),
    data: cvVersionEmptyContent,
    textQuery: emptyContentViewByText('Errata'),
  },
  {
    name: 'Files',
    countKey: 'file_count',
    autoCompleteUrl: '/files/auto_complete_search',
    dataUrl: api.getApiUrl('/files/compare'),
    data: cvVersionFilesCompareThreeContentTypesData,
    textQuery: [
      head(cvVersionFilesCompareThreeContentTypesData.results).name,
      last(cvVersionFilesCompareThreeContentTypesData.results).name],
  },
];

const testConfigViewBySame = [
  {
    name: 'Repositories',
    autoCompleteUrl: '/repositories/auto_complete_search',
    dataUrl: api.getApiUrl('/repositories/compare'),
    data: cvCompareRepositoriesData,
    textQuery: [
      head(cvCompareRepositoriesData.results).name,
      last(cvCompareRepositoriesData.results).name],
  },
  {
    name: 'RPM packages',
    countKey: 'rpm_count',
    autoCompleteUrl: '/packages/auto_complete_search',
    dataUrl: api.getApiUrl('/packages/compare'),
    data: cvVersionRPMPackagesCompareThreeContentTypesData,
    textQuery: [
      head(cvVersionRPMPackagesCompareThreeContentTypesData.results).nvrea,
      last(cvVersionRPMPackagesCompareThreeContentTypesData.results).nvrea],
  },
  {
    name: 'Errata',
    countKey: 'erratum_count',
    autoCompleteUrl: '/errata/auto_complete_search',
    dataUrl: api.getApiUrl('/errata/compare'),
    data: cvVersionErrataCompareThreeContentTypesData,
    textQuery: [
      head(cvVersionErrataCompareThreeContentTypesData.results).name,
      last(cvVersionErrataCompareThreeContentTypesData.results).name],
  },
  {
    name: 'Files',
    countKey: 'file_count',
    autoCompleteUrl: '/files/auto_complete_search',
    dataUrl: api.getApiUrl('/files/compare'),
    data: cvVersionEmptyContent,
    textQuery: emptyContentViewByText('Files'),
  },
];

test('Can make an API call and show comparison of two versions with all content types and sort tables', async (done) => {
  const autoCompleteContentTypesScope = testConfigAllContentTypes.map(({ autoCompleteUrl }) =>
    mockAutocomplete(nockInstance, autoCompleteUrl));

  const scopeContentTypes = testConfigAllContentTypes.map(({ dataUrl, data }) =>
    nockInstance.get(dataUrl).query(true).reply(200, data));

  const scopeCVDetails = nockInstance
    .get(cvDetails)
    .query(true)
    .reply(200, cvDetailsData);

  const scopeVersionOneDetails = nockInstance
    .get(versionDetails(15))
    .query(true)
    .reply(200, versionOneDetailsData);
  const scopeVersionTwoDetails = nockInstance
    .get(versionDetails(17))
    .query(true)
    .reply(200, versionTwoDetailsData);
  const sortedRpmTabScope = nockInstance
    .get(sortedRpmPackagesPath)
    .reply(200, cvCompareRepositoriesData);

  const { queryByText, queryAllByText, getAllByText } = renderWithRedux(
    withCVRoute(<CVVersionCompare
      cvId={4}
      versionIds={versionIdsAllContentTypes}
      versionLabels={versionLabelsAllContentTypes}
    />),
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(`Version ${versionLabelsAllContentTypes.versionOneLabel}`)).toBeNull();
  expect(queryByText(`Version ${versionLabelsAllContentTypes.versionTwoLabel}`)).toBeNull();

  // Assert that the CV version is now showing on the screen, but wait for it to appear.

  await patientlyWaitFor(() => {
    expect(getAllByText(`Version ${versionLabelsAllContentTypes.versionOneLabel}`)).toBeTruthy();
  });

  await patientlyWaitFor(() => {
    expect(getAllByText(`Version ${versionLabelsAllContentTypes.versionTwoLabel}`)).toBeTruthy();
  });
  // Ensure that tab exists on the screen
  await patientlyWaitFor(() => {
    testConfigAllContentTypes.forEach(({ name, textQuery }) => {
      expect(queryByText(name)).toBeTruthy();
      textQuery.forEach(query => expect(queryAllByText(query)).toBeTruthy());
    });
  });

  // Can sort rendered table
  const rpmTab = queryByText('RPM packages');
  fireEvent.click(rpmTab);
  await patientlyWaitFor(() => {
    expect(queryByText('Name')).toBeTruthy();
  });
  fireEvent.click(queryByText('Name'));

  assertNockRequest(scopeCVDetails);
  assertNockRequest(scopeVersionOneDetails);
  assertNockRequest(scopeVersionTwoDetails);
  scopeContentTypes.map(cv => assertNockRequest(cv));
  autoCompleteContentTypesScope.map(cv => assertNockRequest(cv));
  assertNockRequest(sortedRpmTabScope);
  act(done);
});

test('Can make an API call and compare two versions with three content types', async (done) => {
  const autoCompleteContentTypesScope = testConfigThreeContentTypes.map(({ autoCompleteUrl }) =>
    mockAutocomplete(nockInstance, autoCompleteUrl));
  const scopeContentTypes = testConfigThreeContentTypes.map(({ dataUrl, data }) =>
    nockInstance.get(dataUrl).query(true).reply(200, data));
  const scopeCVDetails = nockInstance
    .get(cvDetails)
    .query(true)
    .reply(200, cvDetailsData);
  const scopeVersionOneDetails = nockInstance
    .get(versionDetails(14))
    .query(true)
    .reply(200, versionThreeDetailsData);
  const scopeVersionTwoDetails = nockInstance
    .get(versionDetails(15))
    .query(true)
    .reply(200, versionOneDetailsData);
  const { queryByText, queryAllByText, getAllByText } = renderWithRedux(
    withCVRoute(<CVVersionCompare
      cvId={4}
      versionIds={versionIdsThreeContentTypes}
      versionLabels={versionLabelsThreeContentTypes}
    />),
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(`Version ${versionLabelsThreeContentTypes.versionOneLabel}`)).toBeNull();
  expect(queryByText(`Version ${versionLabelsThreeContentTypes.versionTwoLabel}`)).toBeNull();

  // Assert that the CV version is now showing on the screen, but wait for it to appear.

  await patientlyWaitFor(() => {
    expect(getAllByText(`Version ${versionLabelsThreeContentTypes.versionOneLabel}`)).toBeTruthy();
  });

  await patientlyWaitFor(() => {
    expect(getAllByText(`Version ${versionLabelsThreeContentTypes.versionTwoLabel}`)).toBeTruthy();
  });
  // Ensure that tab exists on the screen
  await patientlyWaitFor(() => {
    testConfigThreeContentTypes.forEach(({ name, textQuery }) => {
      expect(queryByText(name)).toBeTruthy();
      textQuery.forEach(query => expect(queryAllByText(query)).toBeTruthy());
    });
  });


  assertNockRequest(scopeCVDetails);
  assertNockRequest(scopeVersionOneDetails);
  assertNockRequest(scopeVersionTwoDetails);
  scopeContentTypes.map(cv => assertNockRequest(cv));
  autoCompleteContentTypesScope.map(cv => assertNockRequest(cv));
  act(done);
});

test('Can select two versions and click compare button', async (done) => {
  const autoCompleteContentTypesScope = testConfigAllContentTypes.map(({ autoCompleteUrl }) =>
    mockAutocomplete(nockInstance, autoCompleteUrl));
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scopeContentTypes = testConfigAllContentTypes.map(({ dataUrl, data }) =>
    nockInstance.get(dataUrl).query(true).reply(200, data));
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsData);
  const scopeCVDetails = nockInstance
    .get(cvDetails)
    .query(true)
    .reply(200, cvDetailsData);
  const scopeVersionOneDetails = nockInstance
    .get(versionDetails(15))
    .query(true)
    .reply(200, versionOneDetailsData);
  const scopeVersionTwoDetails = nockInstance
    .get(versionDetails(17))
    .query(true)
    .reply(200, versionTwoDetailsData);
  const { getByLabelText, getByText } = renderWithRedux(
    withCVRoute(<ContentViewVersions cvId={4} details={cvDetailsData} />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(getByLabelText('Select version 15')).toBeInTheDocument();
    expect(getByLabelText('Select version 17')).toBeInTheDocument();
    expect(getByLabelText('compare_two_versions')).toHaveAttribute('disabled');
  });
  fireEvent.click(getByLabelText('Select version 15'));
  fireEvent.click(getByLabelText('Select version 17'));

  await patientlyWaitFor(() => {
    expect(getByLabelText('compare_two_versions')).toBeInTheDocument();
  });
  fireEvent.click(getByLabelText('compare_two_versions'));
  await patientlyWaitFor(() => {
    expect(getByText('Compare')).toBeInTheDocument();
  });

  scopeContentTypes.map(cv => assertNockRequest(cv));
  autoCompleteContentTypesScope.map(cv => assertNockRequest(cv));
  assertNockRequest(scopeVersionOneDetails);
  assertNockRequest(scopeVersionTwoDetails);
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(scopeCVDetails);
  act(done);
});

test('Can select two versions with no content and click compare button', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsData);
  const scopeCVDetails = nockInstance
    .get(cvDetails)
    .query(true)
    .reply(200, cvDetailsData);
  const scopeVersionOneDetails = nockInstance
    .get(versionDetails(12))
    .query(true)
    .reply(200, emptyStateVersionOneData);
  const scopeVersionTwoDetails = nockInstance
    .get(versionDetails(13))
    .query(true)
    .reply(200, empptyStateVersionTwoData);
  const { getByLabelText, getByText } = renderWithRedux(
    withCVRoute(<ContentViewVersions cvId={4} details={cvDetailsData} />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(getByLabelText('Select version 12')).toBeInTheDocument();
    expect(getByLabelText('Select version 13')).toBeInTheDocument();
    expect(getByLabelText('compare_two_versions')).toHaveAttribute('disabled');
  });
  fireEvent.click(getByLabelText('Select version 12'));
  fireEvent.click(getByLabelText('Select version 13'));

  await patientlyWaitFor(() => {
    expect(getByLabelText('compare_two_versions')).toBeInTheDocument();
  });
  fireEvent.click(getByLabelText('compare_two_versions'));
  await patientlyWaitFor(() => {
    expect(getByText('Versions to compare')).toBeInTheDocument();
  });

  assertNockRequest(scopeVersionOneDetails);
  assertNockRequest(scopeVersionTwoDetails);
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(scopeCVDetails);
  act(done);
});

test('Can select viewing by "Different" in the dropdown and see the content in either of the versions but not both', async (done) => {
  const autoCompleteContentTypesScope = testConfigViewByDifferent.map(({ autoCompleteUrl }) =>
    mockAutocomplete(nockInstance, autoCompleteUrl));
  const scopeContentTypes = testConfigViewByDifferent.map(({ dataUrl, data }) =>
    nockInstance.persist().get(dataUrl).query(true).reply(200, data));
  const scopeCVDetails = nockInstance
    .get(cvDetails)
    .query(true)
    .reply(200, cvDetailsData);
  const scopeVersionOneDetails = nockInstance
    .get(versionDetails(14))
    .query(true)
    .reply(200, versionThreeDetailsData);
  const scopeVersionTwoDetails = nockInstance
    .get(versionDetails(15))
    .query(true)
    .reply(200, versionOneDetailsData);
  const {
    queryByText,
    queryAllByText,
    getByLabelText,
    getByText,
  } = renderWithRedux(
    withCVRoute(<CVVersionCompare
      cvId={4}
      versionIds={versionIdsThreeContentTypes}
      versionLabels={versionLabelsThreeContentTypes}
    />),
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(`Version ${versionLabelsThreeContentTypes.versionOneLabel}`)).toBeNull();
  expect(queryByText(`Version ${versionLabelsThreeContentTypes.versionTwoLabel}`)).toBeNull();

  // Assert that the CV version is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(getByText(`Version ${versionLabelsThreeContentTypes.versionOneLabel}`)).toBeTruthy();
  });

  await patientlyWaitFor(() => {
    expect(getByText(`Version ${versionLabelsThreeContentTypes.versionTwoLabel}`)).toBeTruthy();
  });

  fireEvent.click(getByText('All'));
  await patientlyWaitFor(() => {
    expect(getByLabelText('View by Different')).toBeTruthy();
  });
  fireEvent.click(getByLabelText('View by Different'));

  await patientlyWaitFor(() => {
    testConfigViewByDifferent.forEach(({ name }) => {
      expect(queryByText(name)).toBeTruthy();
    });
    expect(getByText('No matching Repositories found.')).toBeTruthy();
  });

  (testConfigViewByDifferent.find(({ name }) => name === 'Files')).textQuery.forEach(query => expect(queryAllByText(query)).toBeTruthy());

  fireEvent.click(getByText('RPM packages'));
  await patientlyWaitFor(() => {
    expect(getByText('No matching RPM packages found.')).toBeTruthy();
  });
  fireEvent.click(getByText('Errata'));
  await patientlyWaitFor(() => {
    expect(getByText('No matching Errata found.')).toBeTruthy();
  });

  assertNockRequest(scopeCVDetails);
  assertNockRequest(scopeVersionOneDetails);
  assertNockRequest(scopeVersionTwoDetails);
  scopeContentTypes.map(cv => assertNockRequest(cv));
  autoCompleteContentTypesScope.map(cv => assertNockRequest(cv));
  act(done);
});

test('Can select viewing by "Same" in the dropdown and see the content in common for any two versions', async (done) => {
  const autoCompleteContentTypesScope = testConfigViewBySame.map(({ autoCompleteUrl }) =>
    mockAutocomplete(nockInstance, autoCompleteUrl));
  const scopeContentTypes = testConfigViewBySame.map(({ dataUrl, data }) =>
    nockInstance.persist().get(dataUrl).query(true).reply(200, data));
  const scopeCVDetails = nockInstance
    .get(cvDetails)
    .query(true)
    .reply(200, cvDetailsData);
  const scopeVersionOneDetails = nockInstance
    .get(versionDetails(14))
    .query(true)
    .reply(200, versionThreeDetailsData);
  const scopeVersionTwoDetails = nockInstance
    .get(versionDetails(15))
    .query(true)
    .reply(200, versionOneDetailsData);
  const {
    queryByText,
    queryAllByText,
    getByLabelText,
    getByText,
  } = renderWithRedux(
    withCVRoute(<CVVersionCompare
      cvId={4}
      versionIds={versionIdsThreeContentTypes}
      versionLabels={versionLabelsThreeContentTypes}
    />),
    renderOptions,
  );

  expect(queryByText(`Version ${versionLabelsThreeContentTypes.versionOneLabel}`)).toBeNull();
  expect(queryByText(`Version ${versionLabelsThreeContentTypes.versionTwoLabel}`)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(`Version ${versionLabelsThreeContentTypes.versionOneLabel}`)).toBeTruthy();
  });
  await patientlyWaitFor(() => {
    expect(getByText(`Version ${versionLabelsThreeContentTypes.versionTwoLabel}`)).toBeTruthy();
  });
  fireEvent.click(getByText('All'));
  await patientlyWaitFor(() => {
    expect(getByLabelText('View by Same')).toBeTruthy();
  });
  fireEvent.click(getByLabelText('View by Same'));
  await patientlyWaitFor(() => {
    testConfigViewBySame.forEach(({ name }) => {
      expect(queryByText(name)).toBeTruthy();
    });
    (testConfigViewBySame.filter(({ name }) => !(name === 'Files'))).forEach(({ textQuery }) => {
      textQuery.forEach(query => expect(queryAllByText(query)).toBeTruthy());
    });
  });

  expect(getByText('Files')).toBeTruthy();
  fireEvent.click(getByText('Files'));
  await patientlyWaitFor(() => {
    expect(getByText('No matching Files found.')).toBeTruthy();
  });
  assertNockRequest(scopeCVDetails);
  assertNockRequest(scopeVersionOneDetails);
  assertNockRequest(scopeVersionTwoDetails);
  scopeContentTypes.map(cv => assertNockRequest(cv));
  autoCompleteContentTypesScope.map(cv => assertNockRequest(cv));
  act(done);
});
