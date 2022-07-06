import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockAutocomplete, mockForemanAutocomplete, mockSetting } from '../../../../../../test-utils/nockWrapper';
import api, { foremanApi } from '../../../../../../services/api';
import CONTENT_VIEWS_KEY from '../../../../ContentViewsConstants';
import ContentViewVersions from '../../ContentViewVersions';
import cvVersionsData from './versionsResponseData.fixtures.json';
import environmentPathsData from './versionRemoveEnvPaths.fixtures';
import cvVersionRemoveResponse from './cvVersionRemoveResponse.fixture.json';
import cvDetailData from '../../../../__tests__/mockDetails.fixtures.json';
import affectedHostData from './cvAffectedHosts.fixture';
import affectedActivationKeysData from './cvAffectedActivationKeys.fixture.json';
import cVDropDownOptionsData from './cvDropDownOptionsResponse.fixture';

const environmentPathsPath = api.getApiUrl('/organizations/1/environments/paths');

const renderOptions = { apiNamespace: `${CONTENT_VIEWS_KEY}_2` };
const cvVersions = api.getApiUrl('/content_view_versions');
const autocompleteUrl = '/content_view_versions/auto_complete_search';
const cvVersionRemoveUrl = api.getApiUrl('/content_views/2/remove');

const hostURL = foremanApi.getApiUrl('/hosts');

const activationKeyURL = api.getApiUrl('/activation_keys');

const cVDropDownOptionsPath = api.getApiUrl('/content_views?organization_id=1&include_permissions=true&environment_id=3&include_default=true&full_result=true');
// const taskPollingUrl = '/foreman_tasks/api/tasks/6b900ff8-62bb-42ac-8c45-da86b7258520';

let firstVersion;
let searchDelayScope;
let autoSearchScope;
let envScope;

beforeEach(() => {
  const { results } = cvVersionsData;
  [firstVersion] = results;
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 0);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing');
  envScope = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);
});

afterEach(() => {
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
    <ContentViewVersions cvId={2} details={cvDetailData} />,
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

test('Can open Remove wizard and remove version from simple environment', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsData);

  const envPathRemovalScope = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);

  const cvVersionRemoveParams = { id: 2, environment_ids: [4] };

  const versionRemovalScope = nockInstance
    .put(cvVersionRemoveUrl, cvVersionRemoveParams)
    .reply(202, cvVersionRemoveResponse);


  const {
    getByText, getAllByText, getByLabelText, getAllByLabelText, queryByText,
  } = renderWithRedux(
    <ContentViewVersions cvId={2} details={cvDetailData} />,
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(`Version ${firstVersion.version}`)).toBeNull();
  // Assert that the CV version is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(getByText(`Version ${firstVersion.version}`)).toBeTruthy();
  });
  // Expand Row Action
  expect(getAllByLabelText('Actions')[0]).toHaveAttribute('aria-expanded', 'false');
  fireEvent.click(getAllByLabelText('Actions')[0]);
  expect(getAllByLabelText('Actions')[0]).toHaveAttribute('aria-expanded', 'true');
  fireEvent.click(getByText('Remove from environments'));
  await patientlyWaitFor(() => {
    expect(getByText('Remove Version')).toBeInTheDocument();
  });
  fireEvent.click(getByLabelText('Select row 1'));
  fireEvent.click(getByText('Next'));
  await patientlyWaitFor(() => {
    expect(getByText('Review details')).toBeInTheDocument();
  });
  expect(getAllByText('qa1')[0].closest('a'))
    .toHaveAttribute('href', '/lifecycle_environments/4');
  fireEvent.click(getAllByText('Remove')[0]);
  assertNockRequest(scope);
  assertNockRequest(autocompleteScope);
  assertNockRequest(envPathRemovalScope);
  assertNockRequest(versionRemovalScope, done);
});

test('Can open Remove wizard and remove version from environment with hosts', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const hostAutocompleteUrl = '/hosts/auto_complete_search';
  const hostAutocompleteScope = mockForemanAutocomplete(nockInstance, hostAutocompleteUrl);
  const hostSearchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 0);
  const hostAutoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing');

  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsData);

  const envPathRemovalScope = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);

  const hostScope = nockInstance
    .get(hostURL)
    .query(true)
    .reply(200, affectedHostData);

  const cVDropDownOptionsScope = nockInstance
    .get(cVDropDownOptionsPath)
    .reply(200, cVDropDownOptionsData);

  const cvVersionRemoveParams = {
    id: 2, environment_ids: [6], system_content_view_id: 2, system_environment_id: 3,
  };

  const versionRemovalScope = nockInstance
    .put(cvVersionRemoveUrl, cvVersionRemoveParams)
    .reply(202, cvVersionRemoveResponse);


  const {
    getByText, getAllByText, getByLabelText, getAllByLabelText, queryByText,
  } = renderWithRedux(
    <ContentViewVersions cvId={2} details={cvDetailData} />,
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(`Version ${firstVersion.version}`)).toBeNull();
  // Assert that the CV version is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(getByText(`Version ${firstVersion.version}`)).toBeTruthy();
  });
  // Expand Row Action
  expect(getAllByLabelText('Actions')[0]).toHaveAttribute('aria-expanded', 'false');
  fireEvent.click(getAllByLabelText('Actions')[0]);
  expect(getAllByLabelText('Actions')[0]).toHaveAttribute('aria-expanded', 'true');
  fireEvent.click(getByText('Remove from environments'));
  await patientlyWaitFor(() => {
    expect(getByText('Remove Version')).toBeInTheDocument();
  });
  fireEvent.click(getByLabelText('Select row 3'));
  fireEvent.click(getByText('Next'));
  await patientlyWaitFor(() => {
    expect(getByText('Select lifecycle environment')).toBeInTheDocument();
    expect(getByText('Show hosts')).toBeInTheDocument();
  });
  expect(getByText('affectedHost.example.com')).toBeInTheDocument();
  fireEvent.click(getByLabelText('test1'));
  await patientlyWaitFor(() => {
    expect(getByText('Select content view')).toBeInTheDocument();
    expect(getByText('Select a content view')).toBeInTheDocument();
  });
  fireEvent.click(getByText('Select a content view'));
  await patientlyWaitFor(() => {
    expect(getByText('cv2')).toBeInTheDocument();
  });
  fireEvent.click(getByText('cv2'));
  fireEvent.click(getByText('Next'));
  await patientlyWaitFor(() => {
    expect(getByText('Review details')).toBeInTheDocument();
    expect(getByText('1 host will be moved to content view cv2 in')).toBeInTheDocument();
  });
  fireEvent.click(getAllByText('Remove')[0]);
  assertNockRequest(scope);
  assertNockRequest(autocompleteScope);
  assertNockRequest(hostAutocompleteScope);
  assertNockRequest(hostSearchDelayScope);
  assertNockRequest(hostAutoSearchScope);
  assertNockRequest(hostScope);
  assertNockRequest(cVDropDownOptionsScope);
  assertNockRequest(envPathRemovalScope);
  assertNockRequest(versionRemovalScope, done);
});

test('Can open Remove wizard and remove version from environment with activation keys', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const akAutocompleteUrl = '/activation_keys/auto_complete_search';
  const akAutocompleteScope = mockAutocomplete(nockInstance, akAutocompleteUrl);
  const akSearchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 0);
  const akAutoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing');

  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, cvVersionsData);

  const envPathRemovalScope = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);

  const activationKeysScope = nockInstance
    .get(activationKeyURL)
    .query(true)
    .reply(200, affectedActivationKeysData);

  const cVDropDownOptionsScope = nockInstance
    .get(cVDropDownOptionsPath)
    .reply(200, cVDropDownOptionsData);

  const cvVersionRemoveParams = {
    id: 2, environment_ids: [7], key_content_view_id: 2, key_environment_id: 3,
  };

  const versionRemovalScope = nockInstance
    .put(cvVersionRemoveUrl, cvVersionRemoveParams)
    .reply(202, cvVersionRemoveResponse);


  const {
    getByText, getAllByText, getByLabelText, getAllByLabelText, queryByText,
  } = renderWithRedux(
    <ContentViewVersions cvId={2} details={cvDetailData} />,
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(`Version ${firstVersion.version}`)).toBeNull();
  // Assert that the CV version is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(getByText(`Version ${firstVersion.version}`)).toBeTruthy();
  });
  // Expand Row Action
  expect(getAllByLabelText('Actions')[0]).toHaveAttribute('aria-expanded', 'false');
  fireEvent.click(getAllByLabelText('Actions')[0]);
  expect(getAllByLabelText('Actions')[0]).toHaveAttribute('aria-expanded', 'true');
  fireEvent.click(getByText('Remove from environments'));
  await patientlyWaitFor(() => {
    expect(getByText('Remove Version')).toBeInTheDocument();
  });
  fireEvent.click(getByLabelText('Select row 4'));
  fireEvent.click(getByText('Next'));
  await patientlyWaitFor(() => {
    expect(getByText('Select lifecycle environment')).toBeInTheDocument();
    expect(getByText('Show activation keys')).toBeInTheDocument();
  });
  expect(getByText('test activation key')).toBeInTheDocument();
  fireEvent.click(getByLabelText('test1'));
  await patientlyWaitFor(() => {
    expect(getByText('Select content view')).toBeInTheDocument();
    expect(getByText('Select a content view')).toBeInTheDocument();
  });
  fireEvent.click(getByText('Select a content view'));
  await patientlyWaitFor(() => {
    expect(getByText('cv2')).toBeInTheDocument();
  });
  fireEvent.click(getByText('cv2'));
  fireEvent.click(getByText('Next'));
  await patientlyWaitFor(() => {
    expect(getByText('Review details')).toBeInTheDocument();
    expect(getByText('1 activation key will be moved to content view cv2 in')).toBeInTheDocument();
  });
  fireEvent.click(getAllByText('Remove')[0]);

  assertNockRequest(scope);
  assertNockRequest(autocompleteScope);
  assertNockRequest(akAutocompleteScope);
  assertNockRequest(akSearchDelayScope);
  assertNockRequest(akAutoSearchScope);
  assertNockRequest(activationKeysScope);
  assertNockRequest(cVDropDownOptionsScope);
  assertNockRequest(envPathRemovalScope);
  assertNockRequest(versionRemovalScope, done);
});
