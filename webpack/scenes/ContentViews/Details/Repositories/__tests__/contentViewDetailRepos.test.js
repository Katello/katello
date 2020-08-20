import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';

import nock, { nockInstance, assertNockRequest, mockAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import CONTENT_VIEWS_KEY from '../../../ContentViewsConstants';
import ContentViewRepositories from '../ContentViewRepositories';

const repoData = require('./contentViewDetailRepos.fixtures.json');

const autocompleteUrl = '/repositories/auto_complete_search';
const renderOptions = { apiNamespace: `${CONTENT_VIEWS_KEY}_1` };
const cvAllRepos = api.getApiUrl('/content_views/1/repositories/show_all');
const cvRepos = api.getApiUrl('/content_views/1/repositories');

let firstRepo;
let searchDelayScope;
let autoSearchScope;
beforeEach(() => {
  const { results } = repoData;
  [firstRepo] = results;
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', true);
});

afterEach(() => {
  nock.cleanAll();
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
});

test('Can call API and show repositories on page load', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const scope = nockInstance
    .get(cvAllRepos)
    .query(true)
    .reply(200, repoData);

  const { getByText, queryByText } = renderWithRedux(
    <ContentViewRepositories cvId={1} />,
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(firstRepo.name)).toBeNull();
  // Assert that the repo name is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => expect(getByText(firstRepo.name)).toBeTruthy());


  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

test('Can filter by repository type', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const allTypesScope = nockInstance
    .get(cvAllRepos)
    .query({ 'content_type[]': ['yum', 'file', 'docker', 'ostree'] })
    .reply(200, repoData);

  // With the yum checkbox unchecked, we can expect the query params to not include 'yum'
  const noYumScope = nockInstance
    .get(cvAllRepos)
    .query({ 'content_type[]': ['file', 'docker', 'ostree'] })
    .reply(200, repoData);

  const { getByLabelText } = renderWithRedux(<ContentViewRepositories cvId={1} />, renderOptions);

  const toggleLabel = 'toggle Type';
  const checkboxLabel = 'Yum Repositories checkbox';

  fireEvent.click(getByLabelText(toggleLabel)); // Open type dropdown
  expect(getByLabelText(checkboxLabel).checked).toBeTruthy(); // it is checked by default
  fireEvent.click(getByLabelText(checkboxLabel)); // uncheck
  expect(getByLabelText(checkboxLabel).checked).toBeFalsy(); // assert it is unchecked

  assertNockRequest(autocompleteScope);
  assertNockRequest(allTypesScope);
  assertNockRequest(noYumScope, done);
});

test('Can filter by Not added status', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const allStatusScope = nockInstance
    .get(cvAllRepos)
    .query(true)
    .reply(200, repoData);

  const notAddedScope = nockInstance
    .get(cvRepos)
    .query(params => params.available_for === 'content_view')
    .reply(200, repoData);

  const { getByLabelText } = renderWithRedux(<ContentViewRepositories cvId={1} />, renderOptions);

  const toggleLabel = 'toggle Status';
  const checkboxLabel = 'Added checkbox';

  fireEvent.click(getByLabelText(toggleLabel));
  expect(getByLabelText(checkboxLabel).checked).toBeTruthy();
  fireEvent.click(getByLabelText(checkboxLabel)); // uncheck Added, only Not Added is checked
  expect(getByLabelText(checkboxLabel).checked).toBeFalsy();

  assertNockRequest(autocompleteScope);
  assertNockRequest(allStatusScope);
  assertNockRequest(notAddedScope, done);
});

test('Can filter by Added status', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const allStatusScope = nockInstance
    .get(cvAllRepos)
    .query(true)
    .reply(200, repoData);

  const notAddedScope = nockInstance
    .get(cvRepos)
    .query((params) => {
      const keys = Object.keys(params);
      return keys.length === 1 && keys[0] === 'content_type[]'; // only param is content_type array
    })
    .reply(200, repoData);

  const { getByLabelText } = renderWithRedux(<ContentViewRepositories cvId={1} />, renderOptions);

  const toggleLabel = 'toggle Status';
  const checkboxLabel = 'Not Added checkbox';

  fireEvent.click(getByLabelText(toggleLabel));
  expect(getByLabelText(checkboxLabel).checked).toBeTruthy();
  fireEvent.click(getByLabelText(checkboxLabel)); // uncheck Not Added, only Added is checked
  expect(getByLabelText(checkboxLabel).checked).toBeFalsy();

  assertNockRequest(autocompleteScope);
  assertNockRequest(allStatusScope);
  assertNockRequest(notAddedScope, done);
});
