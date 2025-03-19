import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';

import api from '../../../../../../services/api';
import CVRpmMatchContentModal from '../CVRpmMatchContentModal';
import { nockInstance, assertNockRequest, mockAutocomplete } from '../../../../../../test-utils/nockWrapper';

import CVMatchedContent from './CVRpmMatchContent.fixtures.json';

const firstMatchContent = CVMatchedContent.results[0];
const { nvra: secondMatchContentName } = CVMatchedContent.results[1];
const cvMatchContentPath = api.getApiUrl('/packages');
const autocompleteUrl = '/packages/auto_complete_search';
const autocompleteQuery = {
  organization_id: 1,
  search: '',
};

const onClose = jest.fn();

const MatchContentModal =
  <CVRpmMatchContentModal filterId={194} filterRuleId={13} onClose={onClose} />;

test('Can show matching content modal', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
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
  assertNockRequest(cvMatchContentscope);
  done();
});

test('Can search with filter', async (done) => {
  const matchQuery = {
    organization_id: 1,
    search: `nvra = ${firstMatchContent.nvra}`,
  };
  const searchResults = [
    {
      completed: `nvra = ${firstMatchContent.nvra}`,
      part: 'and',
      label: `nvra = ${firstMatchContent.nvra} and`,
      category: 'Operators',
    },
    {
      completed: `nvra = ${firstMatchContent.nvra}`,
      part: 'or',
      label: `nvra = ${firstMatchContent.nvra} or`,
      category: 'Operators',
    },
  ];
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const secondGetMatchContentscope = mockAutocomplete(
    nockInstance,
    autocompleteUrl,
    matchQuery,
    searchResults,
  );
  const getMatchContentscope = nockInstance
    .get(cvMatchContentPath)
    .query(true)
    .reply(200, CVMatchedContent);

  const { queryByText, getByLabelText } = renderWithRedux(MatchContentModal);

  await patientlyWaitFor(() => {
    expect(queryByText('Matching content')).toBeInTheDocument();
    expect(queryByText(secondMatchContentName)).toBeInTheDocument();
  });

  getByLabelText('Search input').focus();
  fireEvent.change(getByLabelText('Search input'), { target: { value: `nvra = ${firstMatchContent.nvra}` } });

  await patientlyWaitFor(() => {
    expect(queryByText(`nvra = ${firstMatchContent.nvra} and`)).toBeInTheDocument();
    expect(queryByText(firstMatchContent.nvra)).toBeInTheDocument();
    expect(queryByText(`nvra = ${secondMatchContentName} and`)).not.toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(getMatchContentscope);
  assertNockRequest(secondGetMatchContentscope);
  done();
});
