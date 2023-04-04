import React from 'react';
import { act, renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { Route } from 'react-router-dom';
import { nockInstance, assertNockRequest, mockAutocomplete } from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import CONTENT_VIEWS_KEY from '../../../ContentViewsConstants';
import ContentViewVersions from '../ContentViewVersions';
import cvVersionsData from './contentViewVersions.fixtures.json';
import emptyCVVersionData from './emptyCVVersion.fixtures.json';
import cvVersionsTasksData from './contentViewVersionsWithTask.fixtures.json';
import contentViewTaskInProgressResponseData from './contentViewTaskInProgressResponse.fixtures.json';
import contentViewTaskResponseData from './contentViewTaskResponse.fixtures.json';
import cvDetailData from '../../../../ContentViews/__tests__/mockDetails.fixtures.json';
import environmentPathsData from '../../../Publish/__tests__/environmentPaths.fixtures.json';
import cvIndexData from '../../../__tests__/contentViewList.fixtures.json';

const cvPromotePath = api.getApiUrl('/content_view_versions/10/promote');
const cvIndexPath = api.getApiUrl('/content_views');
const promoteResponseData = contentViewTaskInProgressResponseData;


const environmentPathsPath = api.getApiUrl('/organizations/1/environments/paths');

const withCVRoute = component => <Route path="/content_views/:id">{component}</Route>;

const renderOptions = {
  apiNamespace: `${CONTENT_VIEWS_KEY}_VERSIONS_5`,
  routerParams: {
    initialEntries: [{ pathname: '/content_views/5' }],
    initialIndex: 1,
  },
};

const cvVersions = api.getApiUrl('/content_view_versions');
const autocompleteUrl = '/content_view_versions/auto_complete_search';
const taskPollingUrl = '/foreman_tasks/api/tasks/6b900ff8-62bb-42ac-8c45-da86b7258520';

let firstVersion;
let envScope;

beforeEach(() => {
  const { results } = cvVersionsData;
  [firstVersion] = results;
  envScope = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);
});

afterEach(() => {
  assertNockRequest(envScope);
});

test('Can call API and show versions on page load', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsData);

  const { getByText, queryByText } = renderWithRedux(
    withCVRoute(<ContentViewVersions cvId={5} details={cvDetailData} />),
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(`Version ${firstVersion.version}`)).toBeNull();
  // Assert that the CV version is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(getByText(`Version ${firstVersion.version}`)).toBeTruthy();
  });
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  act(done);
});

test('Can link to view environment and see publish time', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsData);

  const { getByText, getAllByText } = renderWithRedux(
    withCVRoute(<ContentViewVersions cvId={5} details={cvDetailData} />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    // Able to display multiple env of version with humanized published/promoted date
    expect(getAllByText('Library')[0].closest('a'))
      .toHaveAttribute('href', '/lifecycle_environments/1');
    expect(getByText('5 days ago')).toBeTruthy();
    expect(getAllByText('dev')[0].closest('a'))
      .toHaveAttribute('href', '/lifecycle_environments/2');
    expect(getAllByText('4 days ago')[0]).toBeTruthy();

    // Able to display empty text for version in no environments
    expect(getAllByText('No environments')).toHaveLength(3);
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  act(done);
});

test('Can show package and erratas and link to list page', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsData);

  const { getByText, getAllByText } = renderWithRedux(
    withCVRoute(<ContentViewVersions cvId={5} details={cvDetailData} />),
    renderOptions,
  );


  await patientlyWaitFor(() => {
    expect(getAllByText(8)[0].closest('a'))
      .toHaveAttribute('href', '/content_views/5#/versions/11/packages/');
    expect(getAllByText(15)[0].closest('a'))
      .toHaveAttribute('href', '/content_views/5#/versions/11/errata/');
    expect(getByText(5)).toBeInTheDocument();
    expect(getByText(3)).toBeInTheDocument();
    expect(getByText(7)).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  act(done);
});

test('Can show additional content and link to list page', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsData);

  const { getByText } = renderWithRedux(
    withCVRoute(<ContentViewVersions cvId={5} details={cvDetailData} />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(getByText('3 Files').closest('a'))
      .toHaveAttribute('href', '/content_views/5#/versions/11/files/');
    expect(getByText('1 Deb packages').closest('a'))
      .toHaveAttribute('href', '/versions/11/debPackages');
    expect(getByText('80 Python packages')).toBeInTheDocument();
    expect(getByText('2 OSTree refs')).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  act(done);
});

test('Can load for empty versions', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, emptyCVVersionData);

  const { queryByText } = renderWithRedux(
    withCVRoute(<ContentViewVersions cvId={5} details={cvDetailData} />),
    renderOptions,
  );

  expect(queryByText(`Version ${firstVersion.version}`)).toBeNull();
  await patientlyWaitFor(() =>
    expect(queryByText('No versions yet')).toBeInTheDocument());
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  act(done);
});

test('Can call API and show versions with tasks on page load', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const { results: withTaskResults } = cvVersionsTasksData;
  [firstVersion] = withTaskResults;

  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsTasksData);

  const taskInProgressScope = nockInstance
    .get(taskPollingUrl)
    .times(4)
    .reply(200, contentViewTaskInProgressResponseData);

  const {
    getByLabelText, queryByText,
  } = renderWithRedux(
    withCVRoute(<ContentViewVersions cvId={5} details={cvDetailData} />),
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(`Version ${firstVersion.version}`)).toBeNull();
  // Assert that the CV version and active task is rendered on the screen.
  await patientlyWaitFor(() => {
    expect(queryByText(`Version ${firstVersion.version}`)).toBeInTheDocument();
    expect(getByLabelText('task_presenter')).toBeInTheDocument();
    expect(getByLabelText('task_presenter')).toHaveAttribute('aria-valuenow', '50');
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(taskInProgressScope);
  act(done);// Force the test to stop listening for tasks
});

test('Can open Promote Modal', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const cvScope = nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(200, cvIndexData);
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsData);

  const cvPromoteParams = {
    id: 10, versionEnvironments: [], description: '', environment_ids: [5], force: true,
  };

  const promoteScope = nockInstance
    .post(cvPromotePath, cvPromoteParams)
    .reply(202, promoteResponseData);

  const {
    getByText, queryByText, getByLabelText, getAllByLabelText,
  } = renderWithRedux(
    withCVRoute(<ContentViewVersions cvId={5} details={cvDetailData} />),
    renderOptions,
  );

  expect(queryByText(`Version ${firstVersion.version}`)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getByText(`Version ${firstVersion.version}`)).toBeInTheDocument();
  });
  // Expand Row Action
  expect(getAllByLabelText('Actions')[1]).toHaveAttribute('aria-expanded', 'false');
  fireEvent.click(getAllByLabelText('Actions')[1]);
  expect(getAllByLabelText('Actions')[1]).toHaveAttribute('aria-expanded', 'true');
  fireEvent.click(getByText('Promote'));
  await patientlyWaitFor(() => {
    expect(getByText('Select a lifecycle environment from the available promotion paths to promote new version.')).toBeInTheDocument();
    expect(getByLabelText('prod')).toBeInTheDocument();
  });
  // Select env prod
  fireEvent.click(getByLabelText('prod'));
  fireEvent.click(getByLabelText('promote_content_view'));
  // Modal closes itself
  await patientlyWaitFor(() => {
    expect(queryByText('Select a lifecycle environment from the available promotion paths to promote new version.')).toBeNull();
    expect(getByText(`Version ${firstVersion.version}`)).toBeInTheDocument();
  });
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(promoteScope);
  // Page is refreshed
  assertNockRequest(scope);
  assertNockRequest(cvScope);
  act(done);
});

test('Can reload versions upon task completion', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const { results: withTaskResults } = cvVersionsTasksData;
  [firstVersion] = withTaskResults;
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsTasksData);
  const cvScope = nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(200, cvIndexData);

  const taskSuccessScope = nockInstance
    .get(taskPollingUrl)
    .times(6)
    .reply(200, contentViewTaskResponseData);

  const reloadScope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsData);

  const {
    queryByLabelText, queryByText,
  } = renderWithRedux(
    withCVRoute(<ContentViewVersions cvId={5} details={cvDetailData} />),
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(`Version ${firstVersion.version}`)).toBeNull();

  // Assert that the CV version is shown and active task is not rendered anymore on the screen.
  await patientlyWaitFor(() => {
    expect(queryByLabelText('task_presenter')).not.toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(taskSuccessScope);
  // Assert CV Versions API is called upon task completion
  assertNockRequest(reloadScope);
  assertNockRequest(cvScope);
  act(done);
});

test('Shows call-to-action when there are no versions', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, emptyCVVersionData);

  const scopeWizard = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);

  const { getByText, queryByText } = renderWithRedux(
    withCVRoute(<ContentViewVersions cvId={5} details={cvDetailData} />),
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText('Publish new version')).toBeNull();
  // Assert that the CV version is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(getByText('Publish new version')).toBeInTheDocument();
  });
  fireEvent.click(getByText('Publish new version'));
  await patientlyWaitFor(() => expect(getByText('Publish new version - 1.0')).toBeInTheDocument);

  assertNockRequest(scopeWizard);
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  act(done);
});

test('Hides selectAllCheckbox when there are no versions', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, emptyCVVersionData);

  const { queryByLabelText, queryByText, getByText } = renderWithRedux(
    withCVRoute(<ContentViewVersions cvId={5} details={cvDetailData} />),
    renderOptions,
  );
  // Nothing will show at first, page is loading
  expect(queryByText('Publish new version')).toBeNull();
  // Assert that the CV version is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(getByText('Publish new version')).toBeInTheDocument();
    expect(queryByLabelText('Select all')).not.toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  act(done);
});
