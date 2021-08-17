import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import nock, { nockInstance, assertNockRequest, mockAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import CONTENT_VIEWS_KEY from '../../../ContentViewsConstants';
import ContentViewVersions from '../ContentViewVersions';

const cvVersionsData = require('./contentViewVersions.fixtures.json');
const emptyCVVersionData = require('./emptyCVVersion.fixtures.json');
const cvVersionsTasksData = require('./contentViewVersionsWithTask.fixtures.json');
const contentViewTaskInProgressResponseData = require('./contentViewTaskInProgressResponse.fixtures.json');
const contentViewTaskResponseData = require('./contentViewTaskResponse.fixtures.json');

const cvPromotePath = api.getApiUrl('/content_view_versions/10/promote');
const promoteResponseData = contentViewTaskInProgressResponseData;


const environmentPathsPath = api.getApiUrl('/organizations/1/environments/paths');
const environmentPathsData = require('../../../Publish/__tests__/environmentPaths.fixtures.json');

const renderOptions = { apiNamespace: `${CONTENT_VIEWS_KEY}_1` };
const cvVersions = api.getApiUrl('/content_view_versions/');
const autocompleteUrl = '/content_view_versions/auto_complete_search';
const taskPollingUrl = '/foreman_tasks/api/tasks/6b900ff8-62bb-42ac-8c45-da86b7258520';

let firstVersion;
let searchDelayScope;
let autoSearchScope;
let envScope;

beforeEach(() => {
  const { results } = cvVersionsData;
  [firstVersion] = results;
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', true);
  envScope = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);
});

afterEach(() => {
  nock.cleanAll();
  assertNockRequest(envScope);
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
});

test('Can call API and show versions on page load', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsData);

  const { getByText, queryByText } = renderWithRedux(
    <ContentViewVersions cvId={5} />,
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(`Version ${firstVersion.version}`)).toBeNull();
  // Assert that the CV version is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(getByText(`Version ${firstVersion.version}`)).toBeTruthy();
  });
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

test('Can link to view environment and see publish time', async () => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsData);

  const { getByText, getAllByText } = renderWithRedux(
    <ContentViewVersions cvId={5} />,
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
});

test('Can show package and erratas and link to list page', async () => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsData);

  const { getByText, getAllByText } = renderWithRedux(
    <ContentViewVersions cvId={5} />,
    renderOptions,
  );


  await patientlyWaitFor(() => {
    expect(getAllByText(8)[0].closest('a'))
      .toHaveAttribute('href', '/content_views/5/versions/11/packages/');
    expect(getAllByText(15)[0].closest('a'))
      .toHaveAttribute('href', '/content_views/5/versions/11/errata/');
    expect(getByText(5).closest('a'))
      .toHaveAttribute('href', '/content_views/5/versions/11/errata?queryPagedSearch=%20type%20%3D%20security');
    expect(getByText(3).closest('a'))
      .toHaveAttribute('href', '/content_views/5/versions/11/errata?queryPagedSearch=%20type%20%3D%20bugfix');
    expect(getByText(7).closest('a'))
      .toHaveAttribute('href', '/content_views/5/versions/11/errata?queryPagedSearch=%20type%20%3D%20enhancement');
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
});

test('Can show additional content and link to list page', async () => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsData);

  const { getByText } = renderWithRedux(
    <ContentViewVersions cvId={5} />,
    renderOptions,
  );


  await patientlyWaitFor(() => {
    expect(getByText('3 Files').closest('a'))
      .toHaveAttribute('href', '/content_views/5/versions/11/file/');
    expect(getByText('1 Deb Packages').closest('a'))
      .toHaveAttribute('href', '/content_views/5/versions/11/deb/');
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
});

test('Can load for empty versions', async () => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, emptyCVVersionData);

  const { queryByText } = renderWithRedux(
    <ContentViewVersions cvId={5} />,
    renderOptions,
  );

  expect(queryByText(`Version ${firstVersion.version}`)).toBeNull();
  await patientlyWaitFor(() =>
    expect(queryByText("You currently don't have any versions for this content view.")).toBeInTheDocument());
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
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
    .reply(200, contentViewTaskInProgressResponseData);

  const {
    getByLabelText, queryByText,
  } = renderWithRedux(
    <ContentViewVersions cvId={5} />,
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
  assertNockRequest(taskInProgressScope, done);
});

test('Can reload versions upon task completion', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const { results: withTaskResults } = cvVersionsTasksData;
  [firstVersion] = withTaskResults;
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsTasksData);

  const taskSuccessScope = nockInstance
    .get(taskPollingUrl)
    .reply(200, contentViewTaskResponseData);

  const reloadScope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsData);


  const {
    getByText, queryByLabelText, getByLabelText, queryByText,
  } = renderWithRedux(
    <ContentViewVersions cvId={5} />,
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(`Version ${firstVersion.version}`)).toBeNull();
  // Assert that the CV version and active task is now showing on the screen.
  await patientlyWaitFor(() => {
    expect(queryByText(`Version ${firstVersion.version}`)).toBeInTheDocument();
    expect(getByLabelText('task_presenter')).toBeInTheDocument();
  });
  const { results } = cvVersionsData;
  [firstVersion] = results;

  // Assert that the CV version is shown and active task is not rendered anymore on the screen.
  await patientlyWaitFor(() => {
    expect(getByText(`Version ${firstVersion.version}`)).toBeInTheDocument();
    expect(queryByLabelText('task_presenter')).not.toBeInTheDocument();
  });
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(taskSuccessScope);
  // Assert CV Versions API is called upon task completion
  assertNockRequest(reloadScope, done);
});

test('Can open Promote Modal', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvVersions)
    .times(2)
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
    <ContentViewVersions cvId={5} />,
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
  });
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(promoteScope);
  // Page is refreshed
  assertNockRequest(scope, done);
});
