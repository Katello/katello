/* eslint-disable no-useless-escape */
import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import api, { foremanApi } from '../../../../services/api';
import nock, {
  nockInstance, assertNockRequest, mockAutocomplete, mockSetting, mockForemanAutocomplete,
} from '../../../../test-utils/nockWrapper';
import CONTENT_VIEWS_KEY from '../../ContentViewsConstants';
import ContentViewsPage from '../../ContentViewsPage.js';
import cvIndexData from './CvData.fixtures.json';
import environmentPathsData from './envPathData.fixtures.json';
import cvVersionsData from './cvVersionsData.fixtures.json';
import cvDetailsData from './cvDetails.fixtures.json';
import affectedActivationKeysData from '../../Details/Versions/Delete/__tests__/cvAffectedActivationKeys.fixture.json';
import affectedHostData from './affectedHosts.fixtures.json';
import cVDropDownOptionsData from '../../Details/Versions/Delete/__tests__/cvDropDownOptionsResponse.fixture.json';
import cvDeleteResponse from '../../Details/Versions/Delete/__tests__/cvVersionRemoveResponse.fixture.json';

const cvIndexPath = api.getApiUrl('/content_views?organization_id=1&nondefault=true&include_permissions=true&per_page=20&page=1');
const autocompleteUrl = '/content_views/auto_complete_search';
const renderOptions = { apiNamespace: CONTENT_VIEWS_KEY };
const environmentPathsPath = api.getApiUrl('/organizations/1/environments/paths');

const cvVersionsPath = api.getApiUrl('/content_view_versions');

const cvDetailsPath = api.getApiUrl('/content_views/20');

const activationKeyURL = api.getApiUrl('/activation_keys');

const hostURL = foremanApi.getApiUrl('/hosts');

const cVDropDownOptionsPath = api.getApiUrl('/content_views?organization_id=1&environment_id=9&include_default=true&include_permissions=true&full_result=true');

const cvDeleteUrl = api.getApiUrl('/content_views/20/remove');

let scopeBookmark;
let firstCV;
let searchDelayScope;
let autoSearchScope;
beforeEach(() => {
  const { results } = cvIndexData;
  [firstCV] = results;
  scopeBookmark = nockInstance
    .get('/api/v2/bookmarks')
    .query(true)
    .reply(200, {});
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 0);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing');
});

afterEach(() => {
  nock.cleanAll();
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
});

test('Can call API for CVs and show Delete Wizard for the row', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvIndexPath)
    .reply(200, cvIndexData);

  const envPathDeleteScope = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);

  const cvVersionsScope = nockInstance
    .get(cvVersionsPath)
    .query(true)
    .reply(200, cvVersionsData);

  const cvDetailsScope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, cvDetailsData);

  const {
    getAllByText, getByText, getAllByLabelText, queryByText,
  } =
    renderWithRedux(<ContentViewsPage />, renderOptions);
  expect(queryByText(firstCV.name)).toBeNull();
  // Assert that the CV name is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => expect(queryByText(firstCV.name)).toBeInTheDocument());
  expect(getAllByLabelText('Actions')[0]).toHaveAttribute('aria-expanded', 'false');
  fireEvent.click(getAllByLabelText('Actions')[0]);
  expect(getAllByLabelText('Actions')[0]).toHaveAttribute('aria-expanded', 'true');
  fireEvent.click(getByText('Delete'));
  await patientlyWaitFor(() => expect(getAllByText('Remove versions from environments')[1]).toBeInTheDocument());

  assertNockRequest(scope);
  assertNockRequest(scopeBookmark);
  assertNockRequest(autocompleteScope);
  assertNockRequest(envPathDeleteScope);
  assertNockRequest(cvDetailsScope);
  assertNockRequest(cvVersionsScope, done);
});

test('Can open Delete wizard and delete CV with all steps', async (done) => {
  const hostAutocompleteUrl = '/hosts/auto_complete_search';
  const hostAutocompleteScope = mockForemanAutocomplete(nockInstance, hostAutocompleteUrl);
  const hostSearchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 0);
  const hostAutoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing');
  const akAutocompleteUrl = '/activation_keys/auto_complete_search';
  const akAutocompleteScope = mockAutocomplete(nockInstance, akAutocompleteUrl);
  const akSearchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 0);
  const akAutoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing');

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const scope = nockInstance
    .get(cvIndexPath)
    .reply(200, cvIndexData);

  const envPathDeleteScope = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);

  const cvVersionsScope = nockInstance
    .get(cvVersionsPath)
    .query(true)
    .reply(200, cvVersionsData);

  const cvDetailsScope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, cvDetailsData);

  const cvRedirectScope = nockInstance
    .get(api.getApiUrl('/content_views?organization_id=1&nondefault=true&include_permissions=true'))
    .reply(200, cvIndexData);

  const cvDeleteParams = {
    destroy_content_view: true,
    system_content_view_id: 2,
    system_environment_id: 9,
    key_content_view_id: 2,
    key_environment_id: 9,
    id: 20,
  };

  const cvDeleteScope = nockInstance
    .put(cvDeleteUrl, cvDeleteParams)
    .reply(202, cvDeleteResponse);

  const hostScope = nockInstance
    .get(hostURL)
    .query(true)
    .reply(200, affectedHostData);

  const activationKeysScope = nockInstance
    .get(activationKeyURL)
    .query(true)
    .reply(200, affectedActivationKeysData);

  const cVDropDownOptionsScope = nockInstance
    .get(cVDropDownOptionsPath)
    .times(2)
    .reply(200, cVDropDownOptionsData);

  const {
    getByText, getByLabelText, getAllByLabelText, getAllByText, queryByText,
  } =
    renderWithRedux(<ContentViewsPage />, renderOptions);
  expect(queryByText(firstCV.name)).toBeNull();
  // Assert that the CV name is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => expect(queryByText(firstCV.name)).toBeInTheDocument());
  expect(getAllByLabelText('Actions')[0]).toHaveAttribute('aria-expanded', 'false');
  fireEvent.click(getAllByLabelText('Actions')[0]);
  expect(getAllByLabelText('Actions')[0]).toHaveAttribute('aria-expanded', 'true');
  fireEvent.click(getByText('Delete'));
  await patientlyWaitFor(() => {
    expect(getAllByText('Remove versions from environments')[1]).toBeInTheDocument();
    expect(queryByText('Version 1.0')).toBeInTheDocument();
  });
  fireEvent.click(getByText('Next'));
  await patientlyWaitFor(() => {
    expect(getByText('Select lifecycle environment')).toBeInTheDocument();
    expect(getByText('Show hosts')).toBeInTheDocument();
  });
  fireEvent.click(getByText('Show hosts'));
  await patientlyWaitFor(() => {
    expect(getByText('affectedHost.example.com')).toBeInTheDocument();
  });
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
    expect(getByText('Select lifecycle environment')).toBeInTheDocument();
    expect(getByText('Show activation keys')).toBeInTheDocument();
  });
  fireEvent.click(getByText('Show activation keys'));
  await patientlyWaitFor(() => {
    expect(getByText('test activation key')).toBeInTheDocument();
  });
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
  // Move to Review
  fireEvent.click(getByText('Next'));
  await patientlyWaitFor(() => {
    expect(getAllByText('Review details')[1]).toBeInTheDocument();
    expect(getByText('Environments')).toBeInTheDocument();
    expect(getByText('Content hosts')).toBeInTheDocument();
    expect(getByText('1 host will be moved to content view cv2 in')).toBeInTheDocument();
    expect(getByText('Activation keys')).toBeInTheDocument();
    expect(getByText('1 activation key will be moved to content view cv2 in')).toBeInTheDocument();
  });
  // Delete CV
  fireEvent.click(getAllByText('Delete')[0]);

  assertNockRequest(scope);
  assertNockRequest(scopeBookmark);
  assertNockRequest(autocompleteScope);
  assertNockRequest(envPathDeleteScope);
  assertNockRequest(cvDetailsScope);
  assertNockRequest(cvVersionsScope);
  assertNockRequest(hostAutocompleteScope);
  assertNockRequest(hostSearchDelayScope);
  assertNockRequest(hostAutoSearchScope);
  assertNockRequest(hostScope);
  assertNockRequest(cVDropDownOptionsScope);
  assertNockRequest(akAutocompleteScope);
  assertNockRequest(akSearchDelayScope);
  assertNockRequest(akAutoSearchScope);
  assertNockRequest(activationKeysScope);
  assertNockRequest(cVDropDownOptionsScope);
  assertNockRequest(cvDeleteScope);
  assertNockRequest(cvRedirectScope, done);
});
