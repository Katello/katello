import React from 'react';
import { renderWithRedux, patientlyWaitFor, act } from 'react-testing-lib-wrapper';

import { nockInstance, assertNockRequest, mockAutocomplete, mockSetting } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';
import ACSTable from '../ACSTable';
import acsData from './acsIndex.fixtures.json';

const acsURL = api.getApiUrl('/alternate_content_sources');
const autocompleteUrl = '/alternate_content_sources/auto_complete_search';

let firstAcs;
let searchDelayScope;
let autoSearchScope;

beforeEach(() => {
  const { results } = acsData;
  [firstAcs] = results;
});

test('Can call API and show ACS on page load', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(acsURL)
    .query(true)
    .reply(200, acsData);
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 0);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing');

  const { getByText, queryByText } = renderWithRedux(<ACSTable />);

  // Nothing will show at first, page is loading
  expect(queryByText(firstAcs.name)).toBeNull();
  // Assert that the ACS name is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => expect(getByText(firstAcs.name)).toBeInTheDocument());
  assertNockRequest(autocompleteScope);
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
  assertNockRequest(scope, done);
  act(done);
});

test('Can handle no ACS being present', async (done) => {
  const noResults = {
    total: 0,
    subtotal: 0,
    page: 1,
    per_page: 20,
    results: [],
    can_create: true,
    can_delete: true,
    can_edit: true,
    can_view: true,
  };
  const scope = nockInstance
    .get(acsURL)
    .query(true)
    .reply(200, noResults);

  const { queryByLabelText, queryByText } = renderWithRedux(<ACSTable />);

  expect(queryByText(firstAcs.name)).toBeNull();
  expect(queryByLabelText('Select all')).not.toBeInTheDocument();
  await patientlyWaitFor(() => expect(queryByText("You currently don't have any alternate content sources.")).toBeInTheDocument());
  assertNockRequest(scope, done);
  act(done);
});
