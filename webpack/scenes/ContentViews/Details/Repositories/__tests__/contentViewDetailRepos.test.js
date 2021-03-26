import React from 'react';
import { renderWithRedux, patientlyWaitFor, patientlyWaitForRemoval, fireEvent } from 'react-testing-lib-wrapper';

import nock, { nockInstance, assertNockRequest, mockAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import CONTENT_VIEWS_KEY from '../../../ContentViewsConstants';
import ContentViewRepositories from '../ContentViewRepositories';

const repoData = require('./contentViewDetailRepos.fixtures.json');

const autocompleteUrl = '/repositories/auto_complete_search';
const renderOptions = { apiNamespace: `${CONTENT_VIEWS_KEY}_1` };
const cvAllRepos = api.getApiUrl('/content_views/1/repositories/show_all');
const cvRepos = api.getApiUrl('/content_views/1/repositories');
const repoTypesResponse = [{ name: 'deb' }, { name: 'docker' }, { name: 'file' }, { name: 'ostree' }, { name: 'yum' }];

let firstRepo;
let searchDelayScope;
let autoSearchScope;

beforeEach(() => {
  const { results } = repoData;
  [firstRepo] = results;
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', true);
  nockInstance
    .persist() // match any query to this endpoint, gets cleaned up by `nock.cleanAll()`
    .get(api.getApiUrl('/repositories/repository_types'))
    .query(true)
    .reply(200, repoTypesResponse);
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
    .query(queryObj => !queryObj.content_type) // no content_type param to match all repos
    .reply(200, repoData);

  const noYumScope = nockInstance
    .get(cvAllRepos)
    .query(queryObj => queryObj.content_type === 'yum')
    .reply(200, repoData);

  const { getByLabelText, getByText } =
    renderWithRedux(<ContentViewRepositories cvId={1} />, renderOptions);

  await patientlyWaitForRemoval(() => getByLabelText('Type spinner'));
  // Patternfly's Select component makes it hard to attach a label, the existing options aren't
  // working as expected, so querying by container label and getting the button
  const toggleContainer = getByLabelText('select Type container');
  const toggleButton = toggleContainer.querySelector('button');
  fireEvent.click(toggleButton); // Open type dropdown
  const selectYum = getByLabelText('select Yum Repositories');
  fireEvent.click(selectYum); // select yum repos
  await patientlyWaitForRemoval(() => getByText('Loading'));
  await patientlyWaitFor(() => expect(getByText(firstRepo.name)).toBeTruthy());

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

  const toggleContainer = getByLabelText('select Status container');
  const toggleButton = toggleContainer.querySelector('button');
  fireEvent.click(toggleButton);
  fireEvent.click(getByLabelText('select Not added'));

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

  const addedScope = nockInstance
    .get(cvRepos)
    .query(true)
    .reply(200, repoData);

  const { getByLabelText } = renderWithRedux(<ContentViewRepositories cvId={1} />, renderOptions);

  const toggleContainer = getByLabelText('select Status container');
  const toggleButton = toggleContainer.querySelector('button');
  fireEvent.click(toggleButton);
  fireEvent.click(getByLabelText('select Added'));

  assertNockRequest(autocompleteScope);
  assertNockRequest(allStatusScope);
  assertNockRequest(addedScope, done);
});
