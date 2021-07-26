import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';

import nock, { nockInstance, assertNockRequest, mockAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import CONTENT_VIEWS_KEY from '../../../ContentViewsConstants';
import ContentViewRepositories from '../ContentViewRepositories';

const repoData = require('./contentViewDetailRepos.fixtures.json');

const autocompleteUrl = '/repositories/auto_complete_search';
const renderOptions = { apiNamespace: `${CONTENT_VIEWS_KEY}_1` };
const cvAllRepos = api.getApiUrl('/content_views/1/repositories/show_all');
const repoTypesResponse = [{ name: 'deb' }, { name: 'docker' }, { name: 'file' }, { name: 'ostree' }, { name: 'yum' }];
const cvDetailData = require('../../__tests__/contentViewDetails.fixtures.json');

const cvDetailsPath = api.getApiUrl('/content_views/1');
const cvRepoAddData = require('./contentViewRepoAdd.fixture.json');

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

test('Can enable and disable add repositories button', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const scope = nockInstance
    .get(cvAllRepos)
    .query(true)
    .reply(200, repoData);

  const { getByText, getByLabelText } = renderWithRedux(
    <ContentViewRepositories cvId={1} />,
    renderOptions,
  );

  await patientlyWaitFor(() => expect(getByText(firstRepo.name)).toBeInTheDocument());
  expect(getByLabelText('Select all rows')).toBeInTheDocument();
  expect(getByLabelText('add_repositories')).toHaveAttribute('aria-disabled', 'true');
  getByLabelText('Select all rows').click();
  await patientlyWaitFor(() => {
    expect(getByLabelText('add_repositories')).toHaveAttribute('aria-disabled', 'false');
  });
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

test('Can add repositories', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const cvAddparams = { repository_ids: [107, 106] };

  const repoAddscope = nockInstance
    .put(cvDetailsPath, cvAddparams)
    .reply(200, cvRepoAddData);

  const cvDetailScope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, cvDetailData);

  const scope = nockInstance
    .get(cvAllRepos)
    .query(true)
    .reply(200, repoData);

  const { getByText, getByLabelText } = renderWithRedux(
    <ContentViewRepositories cvId={1} />,
    renderOptions,
  );

  await patientlyWaitFor(() => expect(getByText(firstRepo.name)).toBeInTheDocument());
  expect(getByLabelText('Select all rows')).toBeInTheDocument();
  expect(getByLabelText('add_repositories')).toHaveAttribute('aria-disabled', 'true');
  getByLabelText('Select all rows').click();
  getByLabelText('add_repositories').click();
  assertNockRequest(repoAddscope);

  assertNockRequest(cvDetailScope);
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

test('Can remove repositories', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const cvRemoveParams = { repository_ids: [] };
  const scope = nockInstance
    .get(cvAllRepos)
    .query(true)
    .reply(200, repoData);
  const cvDetailScope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, cvDetailData);
  const repoRemoveScope = nockInstance
    .put(cvDetailsPath, cvRemoveParams)
    .reply(200, cvRepoAddData);

  const { getByText, getByLabelText } = renderWithRedux(
    <ContentViewRepositories cvId={1} />,
    renderOptions,
  );

  await patientlyWaitFor(() => expect(getByText(firstRepo.name)).toBeInTheDocument());
  expect(getByLabelText('Select all rows')).toBeInTheDocument();
  getByLabelText('Select all rows').click();
  await patientlyWaitFor(() => {
    expect(getByLabelText('bulk_actions')).toHaveAttribute('aria-expanded', 'false');
  });
  getByLabelText('bulk_actions').click();
  await patientlyWaitFor(() => {
    expect(getByLabelText('bulk_actions')).toHaveAttribute('aria-expanded', 'true');
    expect(getByLabelText('bulk_remove')).toBeInTheDocument();
  });
  getByLabelText('bulk_remove').click();
  assertNockRequest(repoRemoveScope);

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvDetailScope);
  assertNockRequest(scope, done);
});
