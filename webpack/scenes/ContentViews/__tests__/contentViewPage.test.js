/* eslint-disable no-useless-escape */
import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent, act } from 'react-testing-lib-wrapper';

import CONTENT_VIEWS_KEY from '../ContentViewsConstants';
import ContentViewsPage from '../../ContentViews';
import api from '../../../services/api';
import {
  nockInstance, assertNockRequest, mockAutocomplete,
} from '../../../test-utils/nockWrapper';
import createBasicCVs from './basicContentViews.fixtures';
import cvIndexData from './contentViewList.fixtures.json';
import environmentPathsData from '../Publish/__tests__/environmentPaths.fixtures.json';

const cvIndexPath = api.getApiUrl('/content_views');
const autocompleteUrl = '/content_views/auto_complete_search';
const environmentPathsPath = api.getApiUrl('/organizations/1/environments/paths');
const renderOptions = { apiNamespace: CONTENT_VIEWS_KEY };
const autocompleteQuery = {
  organization_id: 1,
  search: '',
};

let firstCV;
beforeEach(() => {
  const { results } = cvIndexData;
  [firstCV] = results;
});

test('Can call API for CVs and show on screen on page load', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(200, cvIndexData);

  const { queryByText, queryAllByText } = renderWithRedux(<ContentViewsPage />, renderOptions);

  expect(queryByText(firstCV.name)).toBeNull();

  // Assert that the CV name is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(queryByText(firstCV.name)).toBeInTheDocument();
    expect(queryAllByText('Content views')[0]).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  act(done);
});

test('Can show last task and link to it', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(200, cvIndexData);

  const { getByText, queryByText, queryAllByText } =
    renderWithRedux(<ContentViewsPage />, renderOptions);

  expect(queryByText(firstCV.name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(queryByText(firstCV.name)).toBeTruthy();
    // Reads task details and displays link to the task
    expect(getByText('3 days ago').closest('a'))
      .toHaveAttribute('href', '/foreman_tasks/tasks/54088dac-b990-491c-a891-1d7d1a3f5161/');
    // If no task is found display empty text N/A
    expect(queryAllByText('N/A')).toBeTruthy();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  act(done); // Pass jest callback to confirm test is done
});

test('Can show latest version and link to it', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(200, cvIndexData);

  const {
    getByText,
    queryByText,
    queryAllByText,
  } = renderWithRedux(<ContentViewsPage />, renderOptions);

  expect(queryByText(firstCV.name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(queryByText(firstCV.name)).toBeTruthy();
    // Displays link to the latest version
    expect(queryAllByText('Version 1.0')[0].closest('a'))
      .toHaveAttribute('href', '/content_views/2/versions/11/');
    // We do not expect 'Version 1.0' for the rolling CV fixture
    expect(queryAllByText('Version 1.0')).toHaveLength(1);
    // If no task is found display empty text Not yet published if latest version is null
    expect(queryAllByText('Not yet published')[0]).toBeTruthy();
    // Able to display Environment labels with link to the environment
    expect(queryAllByText('Library')[0].closest('a'))
      .toHaveAttribute('href', '/lifecycle_environments/1');
    expect(getByText('dev').closest('a'))
      .toHaveAttribute('href', '/lifecycle_environments/2');
    expect(queryAllByText('Library')[1].closest('a'))
      .toHaveAttribute('href', '/lifecycle_environments/1');
  });
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  act(done); // Pass jest callback to confirm test is done
});

test('Can expand cv and show activation keys and hosts', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(200, cvIndexData);

  const {
    queryByLabelText,
    getAllByLabelText,
    queryByText,
  } = renderWithRedux(<ContentViewsPage />, renderOptions);

  expect(queryByText(firstCV.name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(queryByText(firstCV.name)).toBeTruthy();
  });

  expect(getAllByLabelText('Details')[0]).toHaveAttribute('aria-expanded', 'false');
  // Expand content for first CV
  getAllByLabelText('Details')[0].click();

  await patientlyWaitFor(() => {
    expect(getAllByLabelText('Details')[0]).toHaveAttribute('aria-expanded', 'true');
    // Displays activation key link with count
    expect(queryByLabelText('activation_keys_link_2')).toHaveAttribute('href', '/activation_keys?search=content_view_id+%3D+2');
    expect(queryByLabelText('activation_keys_link_2').textContent).toEqual('1');

    // Displays hosts link with count
    expect(queryByLabelText('host_link_2')).toHaveAttribute('href', '/new/hosts?search=content_view_id%3D2');
    expect(queryByLabelText('host_link_2').textContent).toEqual('1');
    // Content views can be part of a composite content view
    expect(queryByText(/Related composite content views:/)).toBeVisible();
  });

  getAllByLabelText('Details')[0].click();
  // Collapse content for first CV
  await patientlyWaitFor(() => {
    // Details should disappear
    expect(queryByText(/Related composite content views:/)).not.toBeVisible();
  });

  // Expand content for rolling CV
  await patientlyWaitFor(() => {
    getAllByLabelText('Details')[2].click();
    expect(queryByLabelText('host_link_3').textContent).toEqual('1');
    // Rolling content views cannot be part of composite content views
    expect(queryByText(/Related composite content views:/)).not.toBeVisible();
  });
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Can show the correct options in CV kebap menu', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(200, cvIndexData);

  const { getAllByLabelText, queryByText } = renderWithRedux(<ContentViewsPage />, renderOptions);

  await patientlyWaitFor(() => expect(getAllByLabelText('Kebab toggle')[0]).toBeInTheDocument());
  await act(async () => {
    getAllByLabelText('Kebab toggle')[0].click();
  });
  await patientlyWaitFor(async () => {
    // open kebap menu of content view, should contain all available action options
    expect(getAllByLabelText('Kebab toggle')[0]).toHaveAttribute('aria-expanded', 'true');
    expect(queryByText('Publish')).toBeVisible();
    expect(queryByText('Promote')).toBeVisible();
    expect(queryByText('Copy')).toBeVisible();
    expect(queryByText('Delete')).toBeVisible();

    // open kebap menu of rolling content view, should only show 'Delete' action
  });
  await act(async () => {
    getAllByLabelText('Kebab toggle')[2].click();
  });
  await patientlyWaitFor(async () => {
    expect(getAllByLabelText('Kebab toggle')[0]).toHaveAttribute('aria-expanded', 'false');
    expect(getAllByLabelText('Kebab toggle')[2]).toHaveAttribute('aria-expanded', 'true');
    expect(queryByText('Publish')).toBeNull();
    expect(queryByText('Promote')).toBeNull();
    expect(queryByText('Copy')).toBeNull();
    expect(queryByText('Delete')).toBeVisible();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  act(done); // Pass jest callback to confirm test is done
});

test('Can handle no Content Views being present', async (done) => {
  const noResults = {
    total: 0,
    subtotal: 0,
    page: 1,
    per_page: 20,
    results: [],
    can_view: true,
    can_create: true,
  };
  const scope = nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(200, noResults);
  const { queryByText } = renderWithRedux(<ContentViewsPage />, renderOptions);

  expect(queryByText(firstCV.name)).toBeNull();
  await patientlyWaitFor(() => expect(queryByText('You currently have no content views to display')).toBeInTheDocument());
  assertNockRequest(scope);
  act(done);
});

test('Can handle errored response', async (done) => {
  const scope = nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(500);

  const { queryByText } = renderWithRedux(<ContentViewsPage />, renderOptions);

  expect(queryByText(firstCV.name)).toBeNull();
  await patientlyWaitFor(() => expect(queryByText(/Something went wrong! Please check server logs!/i)).toBeInTheDocument());
  assertNockRequest(scope);
  act(done);
});

test('Can handle unpublished Content Views', async (done) => {
  const { results } = cvIndexData;
  const unpublishedCVs = results.map(cv => ({ ...cv, last_published: null }));
  const unpublishedCVData = { ...cvIndexData, results: unpublishedCVs };
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(200, unpublishedCVData);

  const { getAllByText } = renderWithRedux(<ContentViewsPage />, renderOptions);

  await patientlyWaitFor(() => expect(getAllByText(/not yet published/i).length).toBeGreaterThan(0));
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  act(done);
});

test('Can handle pagination', async (done) => {
  const cvIndexLarge = createBasicCVs(100);
  const { results } = cvIndexLarge;
  const cvIndexFirstPage = { ...cvIndexLarge, ...{ results: results.slice(0, 20) } };
  const cvIndexSecondPage = { ...cvIndexLarge, page: 2, results: results.slice(20, 40) };
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);

  // Match first page API request
  const firstPageScope = nockInstance
    .get(cvIndexPath)
    // Using a custom query params matcher because parameters can be strings
    .query(actualQueryObject => (parseInt(actualQueryObject.page, 10) === 1))
    .reply(200, cvIndexFirstPage);

  // Match second page API request
  const secondPageScope = nockInstance
    .get(cvIndexPath)
    // Using a custom query params matcher because parameters can be strings
    .query(actualQueryObject => (parseInt(actualQueryObject.page, 10) === 2))
    .reply(200, cvIndexSecondPage);
  const { queryByText, getAllByLabelText } = renderWithRedux(<ContentViewsPage />, renderOptions);
  // Wait for first paginated page to load and assert only the first page of results are present
  await patientlyWaitFor(() => {
    expect(queryByText(results[0].name)).toBeInTheDocument();
    expect(queryByText(results[19].name)).toBeInTheDocument();
    expect(queryByText(results[21].name)).not.toBeInTheDocument();
  });

  // Label comes from patternfly, if this test fails, check if patternfly updated the label.
  const [top, bottom] = getAllByLabelText('Go to next page');
  expect(top).toBeInTheDocument();
  expect(bottom).toBeInTheDocument();
  bottom.click();
  // Wait for second paginated page to load and assert only the second page of results are present
  await patientlyWaitFor(() => {
    expect(queryByText(results[20].name)).toBeInTheDocument();
    expect(queryByText(results[39].name)).toBeInTheDocument();
    expect(queryByText(results[41].name)).not.toBeInTheDocument();
  });
  assertNockRequest(autocompleteScope);
  assertNockRequest(firstPageScope);
  assertNockRequest(secondPageScope);
  act(done); // Only pass jest callback to the last API request
});

test('Can search for specific Content View', async (done) => {
  const cvname = 'composite one';
  const matchQuery = {
    organization_id: 1,
    search: `name = ${firstCV.name}`,
  };
  const searchResults = [
    {
      completed: 'name = cv1',
      part: 'and',
      label: 'name = cv1 and',
      category: 'Operators',
    },
    {
      completed: 'name = cv1',
      part: 'or',
      label: 'name = cv1 or',
      category: 'Operators',
    },
  ];

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const withSearchScope = mockAutocomplete(
    nockInstance,
    autocompleteUrl,
    matchQuery,
    searchResults,
  );

  const initialScope = nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(200, cvIndexData);

  const {
    getByLabelText,
    getByText,
    queryByText,
  } = renderWithRedux(<ContentViewsPage />, renderOptions);

  await patientlyWaitFor(() => expect(getByText(firstCV.name)).toBeInTheDocument());

  const searchInput = getByLabelText('Search input');
  expect(searchInput).toBeInTheDocument();
  searchInput.focus();
  fireEvent.change(searchInput, { target: { value: `name = ${firstCV.name}` } });

  await patientlyWaitFor(() => {
    expect(getByText(`name = ${firstCV.name} and`)).toBeInTheDocument();
    expect(queryByText(`name = ${cvname} and`)).not.toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(initialScope);
  assertNockRequest(withSearchScope);
  act(done);
});

test('Nothing is shown for empty search', async (done) => {
  const cvname = 'notanactualname';
  const query = `name = \"${cvname}\"`;
  const matchQuery = {
    organization_id: 1,
    search: query,
  };

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const withSearchScope = mockAutocomplete(nockInstance, autocompleteUrl, matchQuery);
  const initialScope = nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(200, cvIndexData);

  const {
    getByLabelText,
    getByText,
    queryByText,
  } = renderWithRedux(<ContentViewsPage />, renderOptions);

  await patientlyWaitFor(() => expect(getByText(firstCV.name)).toBeInTheDocument());

  getByLabelText('Search input').focus();
  fireEvent.change(getByLabelText('Search input'), { target: { value: query } });

  await patientlyWaitFor(() => expect(queryByText(`${query} and`)).not.toBeInTheDocument());

  assertNockRequest(autocompleteScope);
  assertNockRequest(initialScope);
  assertNockRequest(withSearchScope);
  act(done);
});

test('Displays Create Content View and opens modal with Form', async () => {
  const noResults = {
    total: 0,
    subtotal: 0,
    page: 1,
    per_page: 20,
    can_create: true,
    can_view: true,
    results: [],
  };
  nockInstance
    .get(cvIndexPath)
    .query(true)
    .reply(200, noResults);
  const scope = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);
  const {
    getByText, queryByText, getByLabelText,
  } = renderWithRedux(<ContentViewsPage />, renderOptions);
  await patientlyWaitFor(() => expect(queryByText('Create content view')).toBeInTheDocument());

  expect(queryByText('Description')).not.toBeInTheDocument();
  expect(queryByText('Name')).not.toBeInTheDocument();
  expect(queryByText('Label')).not.toBeInTheDocument();
  expect(queryByText('Composite content view')).not.toBeInTheDocument();
  expect(queryByText('Content view')).not.toBeInTheDocument();
  expect(queryByText('Solve dependencies')).not.toBeInTheDocument();
  expect(queryByText('Auto publish')).not.toBeInTheDocument();
  expect(queryByText('Lifecycle Environments')).not.toBeInTheDocument();

  getByLabelText('create_content_view').click();

  expect(getByText('Description')).toBeInTheDocument();
  expect(getByText('Name')).toBeInTheDocument();
  expect(getByText('Label')).toBeInTheDocument();
  expect(getByText('Composite content view')).toBeInTheDocument();
  expect(getByText('Rolling content view')).toBeInTheDocument();
  expect(getByText('Content view')).toBeInTheDocument();
  expect(getByText('Solve dependencies')).toBeInTheDocument();
  expect(queryByText('Auto publish')).not.toBeInTheDocument();
  expect(queryByText('Lifecycle Environments')).not.toBeInTheDocument();
  assertNockRequest(scope);
});

/* eslint-enable no-useless-escape */
