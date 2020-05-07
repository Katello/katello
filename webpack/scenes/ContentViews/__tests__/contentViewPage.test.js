import React from 'react';
import { renderWithApiRedux, waitFor } from 'react-testing-lib-wrapper';

import CONTENT_VIEWS_KEY from '../ContentViewsConstants';
import ContentViewsPage from '../../ContentViews';
import api from '../../../services/api';
import { nockInstance, assertNockRequest } from '../../../test-utils/nockWrapper';


const cvIndexData = require('./contentViewList.fixtures.json');

const cvIndexPath = api.getApiUrl('/content_views');
const renderOptions = { namespace: CONTENT_VIEWS_KEY };

let firstCV;
beforeEach(() => {
  const { results } = cvIndexData;
  [firstCV] = results;
});

test('Can call API for CVs and show on screen on page load', async () => {
  // Mocking API call with nock so it returns the fixture data
  const scope = nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(200, cvIndexData);

  // Using a custom rendering function that sets up both redux and react-router.
  // This allows us to use the component as it is normally used
  const { queryByText } = renderWithApiRedux(<ContentViewsPage />, renderOptions);

  // query* functions will return the element or null if it cannot be found
  // get* functions will return the element or throw an error if it cannot be found
  // Assert that the CV is not showing yet by searching by name and the query returning null
  expect(queryByText(firstCV.name)).toBeNull();
  // Assert that the CV name is now showing on the screen, but wait for it to appear.
  await waitFor(() => expect(queryByText(firstCV.name)).toBeTruthy());
  // Assert request was made and completed, see helper function
  assertNockRequest(scope);
});

test('Can handle no Content Views being present', async () => {
  const noResults = {
    total: 0,
    subtotal: 0,
    page: 1,
    per_page: 20,
    results: [],
  };
  const scope = nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(200, noResults);
  const { queryByText } = renderWithApiRedux(<ContentViewsPage />, renderOptions);

  expect(queryByText(firstCV.name)).toBeNull();
  await waitFor(() => expect(queryByText(/don't have any Content Views/)).toBeTruthy());
  assertNockRequest(scope);
});

test('Can handle errored response', async () => {
  const scope = nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(500);
  const { queryByText } = renderWithApiRedux(<ContentViewsPage />, renderOptions);

  expect(queryByText(firstCV.name)).toBeNull();
  await waitFor(() => expect(queryByText(/unable to retrieve information/i)).toBeTruthy());
  assertNockRequest(scope);
});

test('Can handle loading state while request is being made', () => {
  const scope = nockInstance
    .get(cvIndexPath)
    .delay(2000) // Delay the response so we can check loading state properly
    .query(true)
    .reply(200);

  const { queryByText } = renderWithApiRedux(<ContentViewsPage />, renderOptions);

  expect(queryByText('Loading')).toBeTruthy();
  scope.isDone(); // ensure request is cleaned up
});

test('Can handle unpublished Content Views', async () => {
  const { results } = cvIndexData;
  const unpublishedCVs = results.map(cv => ({ ...cv, last_published: null }));
  const unpublishedCVData = { ...cvIndexData, results: unpublishedCVs };
  const scope = nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(200, unpublishedCVData);

  const { getAllByText } = renderWithApiRedux(<ContentViewsPage />, renderOptions);

  await waitFor(() => expect(getAllByText(/not yet published/i).length).toBeGreaterThan(0));
  assertNockRequest(scope);
});
