import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';


import api from '../../../../../../services/api';
import CVRpmMatchContentModal from '../CVRpmMatchContentModal';
import { nockInstance, assertNockRequest, mockSetting, mockAutocomplete } from '../../../../../../test-utils/nockWrapper';

import CVMatchedContent from './CVRpmMatchContent.fixtures.json';
import CVMatchContentSearch from './CVRpmMatchContentSearch.fixtures.json';

const firstMatchContent = CVMatchedContent.results[0];
const { nvra: secondMatchContentName } = CVMatchedContent.results[1];
const cvMatchContentPath = api.getApiUrl('/packages');
const autocompleteUrl = '/packages/auto_complete_search';

const onClose = jest.fn();

const MatchContentModal =
  <CVRpmMatchContentModal filterId={194} filterRuleId={13} onClose={onClose} />;

let searchDelayScope;
let autoSearchScope;
beforeEach(() => {
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 0);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing');
});

afterEach(() => {
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
});


test('Can show matching content modal', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const cvMatchContentscope = nockInstance
    .get(cvMatchContentPath)
    .query(true)
    .reply(200, CVMatchedContent);

  const { queryByText } = renderWithRedux(MatchContentModal);
  await patientlyWaitFor(() => {
    expect(queryByText('Matching content')).toBeInTheDocument();
    expect(queryByText(firstMatchContent.nvra)).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvMatchContentscope, done);
});

test('Can search with filter', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const getMatchContentscope = nockInstance
    .get(cvMatchContentPath)
    .query(true)
    .reply(200, CVMatchedContent);

  const autocompleteSearchScope = nockInstance
    .get(api.getApiUrl(autocompleteUrl))
    .query(true)
    .reply(200, []);

  const secondGetMatchContentscope = nockInstance
    .get(cvMatchContentPath)
    .query(true)
    .reply(200, CVMatchContentSearch);

  const { queryByText, getByLabelText } = renderWithRedux(MatchContentModal);

  await patientlyWaitFor(() => {
    expect(queryByText('Matching content')).toBeInTheDocument();
    expect(queryByText(secondMatchContentName)).toBeInTheDocument();
  });

  fireEvent.change(getByLabelText(/text input for search/i), { target: { value: `nvra = ${firstMatchContent.nvra}` } });

  await patientlyWaitFor(() => {
    expect(queryByText('Matching content')).toBeInTheDocument();
    expect(queryByText(firstMatchContent.nvra)).toBeInTheDocument();
    expect(queryByText(secondMatchContentName)).not.toBeInTheDocument();
  });


  assertNockRequest(autocompleteScope);
  assertNockRequest(getMatchContentscope);
  assertNockRequest(autocompleteSearchScope);
  assertNockRequest(secondGetMatchContentscope, done);
});
