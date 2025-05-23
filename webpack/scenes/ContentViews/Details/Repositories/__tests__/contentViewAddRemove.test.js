import React from 'react';
import { renderWithRedux, patientlyWaitFor, act, fireEvent } from 'react-testing-lib-wrapper';

import { nockInstance, assertNockRequest, mockAutocomplete } from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import CONTENT_VIEWS_KEY from '../../../ContentViewsConstants';
import ContentViewRepositories from '../ContentViewRepositories';
import repoData from './contentViewDetailRepos.fixtures.json';
import noReposAddedData from './contentViewDetailNoReposAdded.fixtures.json';
import cvDetailData from '../../__tests__/contentViewDetails.fixtures.json';
import cvRepoAddData from './contentViewRepoAdd.fixture.json';

const autocompleteUrl = '/repositories/auto_complete_search';
const renderOptions = { apiNamespace: `${CONTENT_VIEWS_KEY}_1` };
const cvAllRepos = api.getApiUrl('/content_views/1/repositories/show_all');
const cvAddedRepos = api.getApiUrl('/content_views/1/repositories');
const repoTypesResponse = [{ name: 'deb' }, { name: 'docker' }, { name: 'file' }, { name: 'ostree' }, { name: 'yum' }];

const cvDetailsPath = api.getApiUrl('/content_views/1');

let firstRepo;

beforeEach(() => {
  const { results } = repoData;
  [firstRepo] = results;
  nockInstance
    .persist() // match any query to this endpoint, gets cleaned up by `nock.cleanAll()`
    .get(api.getApiUrl('/repositories/repository_types'))
    .query(true)
    .reply(200, repoTypesResponse);
});

jest.mock('react-intl', () => ({ addLocaleData: () => { }, FormattedDate: () => 'mocked' }));

test('Can enable and disable add repositories button', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const noReposScope = nockInstance
    .get(cvAddedRepos)
    .query(true)
    .reply(200, noReposAddedData);
  const scope = nockInstance
    .get(cvAllRepos)
    .query(true)
    .reply(200, repoData);

  const { getByText, getByLabelText } = renderWithRedux(
    <ContentViewRepositories cvId={1} details={cvDetailData} />,
    renderOptions,
  );

  await patientlyWaitFor(() => expect(getByText('Show repositories')).toBeInTheDocument());
  fireEvent.click(getByText('Show repositories'));

  await patientlyWaitFor(() => expect(getByText(firstRepo.name)).toBeInTheDocument());
  expect(getByLabelText('Select all')).toBeInTheDocument();
  expect(getByLabelText('add_repositories')).toHaveAttribute('aria-disabled', 'true');
  fireEvent.click(getByLabelText('Select all'));
  await patientlyWaitFor(() => {
    expect(getByLabelText('add_repositories')).toHaveAttribute('aria-disabled', 'false');
  });
  assertNockRequest(autocompleteScope);
  assertNockRequest(noReposScope);
  assertNockRequest(scope);
  done();
});

test('Can add repositories', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const cvAddparams = { include_permissions: true, repository_ids: [58, 62, 64, 106, 107] };

  const repoAddscope = nockInstance
    .put(cvDetailsPath, cvAddparams)
    .reply(200, cvRepoAddData);

  const cvDetailScope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, cvDetailData);

  const noReposScope = nockInstance
    .get(cvAddedRepos)
    .query(true)
    .reply(200, noReposAddedData);

  const scope = nockInstance
    .get(cvAllRepos)
    .query(true)
    .reply(200, repoData);

  const { getByText, getByLabelText } = renderWithRedux(
    <ContentViewRepositories cvId={1} details={cvDetailData} />,
    renderOptions,
  );

  await patientlyWaitFor(() => expect(getByText('Show repositories')).toBeInTheDocument());
  fireEvent.click(getByText('Show repositories'));

  await patientlyWaitFor(() => expect(getByText(firstRepo.name)).toBeInTheDocument());
  expect(getByLabelText('Select all')).toBeInTheDocument();
  expect(getByLabelText('add_repositories')).toHaveAttribute('aria-disabled', 'true');
  fireEvent.click(getByLabelText('Select all'));
  fireEvent.click(getByLabelText('add_repositories'));
  await patientlyWaitFor(() => expect(getByText(firstRepo.name)).toBeInTheDocument());

  assertNockRequest(repoAddscope);

  assertNockRequest(cvDetailScope);
  assertNockRequest(autocompleteScope);
  assertNockRequest(noReposScope);
  assertNockRequest(scope);
  done();
  act(done);
});

test('Can remove repositories', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const cvRemoveParams = { include_permissions: true, repository_ids: [58, 62, 64] };
  const scope = nockInstance
    .get(cvAddedRepos)
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
    <ContentViewRepositories cvId={1} details={cvDetailData} />,
    renderOptions,
  );

  await patientlyWaitFor(() => expect(getByText(firstRepo.name)).toBeInTheDocument());
  expect(getByLabelText('Select all')).toBeInTheDocument();
  fireEvent.click(getByLabelText('Select all'));
  await patientlyWaitFor(() => {
    expect(getByLabelText('bulk_actions')).toHaveAttribute('aria-expanded', 'false');
  });
  fireEvent.click(getByLabelText('bulk_actions'));
  await patientlyWaitFor(() => {
    expect(getByLabelText('bulk_actions')).toHaveAttribute('aria-expanded', 'true');
    expect(getByLabelText('bulk_remove')).toBeInTheDocument();
  });
  fireEvent.click(getByLabelText('bulk_remove'));
  await patientlyWaitFor(() => expect(getByText(firstRepo.name)).toBeInTheDocument());

  assertNockRequest(repoRemoveScope);

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvDetailScope);
  assertNockRequest(scope);
  done();
  act(done);
});
