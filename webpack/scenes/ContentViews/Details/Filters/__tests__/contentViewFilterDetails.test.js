import React from 'react';
import { Route } from 'react-router'
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';

import ContentViewFilterDetails from '../ContentViewFilterDetails'
import { cvFilterDetailsKey } from '../../../ContentViewsConstants'
import nock, { nockInstance, assertNockRequest, mockAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';

const allPackageGroups = require('./allFilterPackageGroups.fixtures.json');
const cvFilterDetails = require('./contentViewFilterDetail.fixtures.json');
const cvFilterDetailsPath = api.getApiUrl('/content_view_filters/1');
const packageGroupsPath = api.getApiUrl('/package_groups');
const autocompleteUrl = '/package_groups/auto_complete_search';
const renderOptions = {
  apiNamespace: cvFilterDetailsKey(1, 1),
};

let searchDelayScope;
let autoSearchScope;
beforeEach(() => {
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
  // Autosearch can cause some asynchronous issues with the typing timeout, using basic search
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', false);
});

afterEach(() => {
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
  nock.cleanAll();
});

test('Can show filter details and package groups on page load', async (done) => {
  const { name: cvFilterName } = cvFilterDetails;
  const cvFilterScope = nockInstance
    .get(cvFilterDetailsPath)
    .query(true)
    .reply(200, cvFilterDetails);
  const packageGroupsScope = nockInstance
    .get(packageGroupsPath)
    .query(true)
    .reply(200, allPackageGroups)
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const { getByText, queryByText } =
    renderWithRedux(<ContentViewFilterDetails cvId={1} />, renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(cvFilterName)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getByText(cvFilterName)).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(packageGroupsScope, done);
});