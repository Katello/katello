import React from 'react';
import { act, fireEvent, patientlyWaitFor, renderWithRedux } from 'react-testing-lib-wrapper';
import { Route } from 'react-router-dom';
import { assertNockRequest, nockInstance } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';
import ACSExpandableDetails from '../ACSExpandableDetails';
import acsDetails from './acsDetails.fixtures';
import simplifiedAcsDetails from './simplifiedAcsDetails.fixtures.json';
import productsList from './acsProducts.fixtures.json';

const acsDetailsURL = api.getApiUrl('/alternate_content_sources/1');
const withACSRoute = component => <Route path="/alternate_content_sources/:id([0-9]+)">{component}</Route>;
const productsURL = api.getApiUrl('/products');

test('Can show custom ACS details expandable sections with edit buttons', async (done) => {
  const renderOptions = {
    routerParams: {
      initialEntries: [{ pathname: '/alternate_content_sources/1/details' }],
    },
  };
  const acsDetailsScope = nockInstance
    .get(acsDetailsURL)
    .query(true)
    .reply(200, acsDetails);
  const { queryByText, getByLabelText } =
        renderWithRedux(withACSRoute(<ACSExpandableDetails />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText('test_acs')).toBeNull();
  expect(queryByText('Hide details')).toBeNull();
  expect(queryByText('Show smart proxies')).toBeNull();
  expect(queryByText('Show URL and subpaths')).toBeNull();
  expect(queryByText('Show credentials')).toBeNull();
  // Assert that the ACS name and expandable sections
  // are now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs')).toBeInTheDocument();
    expect(queryByText('Hide details')).toBeInTheDocument();
    expect(getByLabelText('edit-details-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Show smart proxies')).toBeInTheDocument();
    expect(getByLabelText('edit-smart-proxies-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Show URL and subpaths')).toBeInTheDocument();
    expect(getByLabelText('edit-urls-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Show credentials')).toBeInTheDocument();
    expect(getByLabelText('edit-credentials-pencil-edit')).toBeInTheDocument();
  });
  assertNockRequest(acsDetailsScope, done);
  act(done);
});

test('Can open and close edit ACS details modal', async (done) => {
  const renderOptions = {
    routerParams: {
      initialEntries: [{ pathname: '/alternate_content_sources/1/details' }],
    },
  };
  const acsDetailsScope = nockInstance
    .get(acsDetailsURL)
    .query(true)
    .reply(200, acsDetails);
  const { queryByText, getByLabelText, queryAllByText } =
        renderWithRedux(withACSRoute(<ACSExpandableDetails />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText('test_acs')).toBeNull();
  expect(queryByText('Hide details')).toBeNull();
  expect(queryByText('Show smart proxies')).toBeNull();
  expect(queryByText('Show URL and subpaths')).toBeNull();
  expect(queryByText('Show credentials')).toBeNull();
  // Assert that the ACS name and expandable sections
  // are now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs')).toBeInTheDocument();
    expect(queryByText('Hide details')).toBeInTheDocument();
    expect(getByLabelText('edit-details-pencil-edit')).toBeInTheDocument();
  });
  const editDetails = getByLabelText('edit-details-pencil-edit');
  fireEvent.click(editDetails);
  // Can open modal
  await patientlyWaitFor(() => {
    expect(queryAllByText('Edit details')).toHaveLength(2);
    expect(getByLabelText('edit_acs_details')).toBeInTheDocument();
  });
  const cancelButton = queryByText('Cancel');
  fireEvent.click(cancelButton);
  // can close modal
  await patientlyWaitFor(() => {
    expect(queryByText('Edit Alternate content source details')).not.toBeInTheDocument();
  });
  assertNockRequest(acsDetailsScope, done);
  act(done);
});

test('Can edit ACS details in the edit modal', async (done) => {
  const renderOptions = {
    routerParams: {
      initialEntries: [{ pathname: '/alternate_content_sources/1/details' }],
    },
  };
  const acsDetailsScope = nockInstance
    .get(acsDetailsURL)
    .times(2)
    .query(true)
    .reply(200, acsDetails);
  const acsEditScope = nockInstance
    .put(acsDetailsURL)
    .reply(200, acsDetails);
  const { queryByText, getByLabelText, queryAllByText } =
        renderWithRedux(withACSRoute(<ACSExpandableDetails />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText('test_acs')).toBeNull();
  expect(queryByText('Hide details')).toBeNull();
  expect(queryByText('Show smart proxies')).toBeNull();
  expect(queryByText('Show URL and subpaths')).toBeNull();
  expect(queryByText('Show credentials')).toBeNull();
  // Assert that the ACS name and expandable sections
  // are now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs')).toBeInTheDocument();
    expect(queryByText('Hide details')).toBeInTheDocument();
    expect(getByLabelText('edit-details-pencil-edit')).toBeInTheDocument();
  });
  const editDetails = getByLabelText('edit-details-pencil-edit');
  expect(queryAllByText('Edit details')).toHaveLength(1);
  fireEvent.click(editDetails);
  // Can open modal
  await patientlyWaitFor(() => {
    expect(queryAllByText('Edit details')).toHaveLength(2);
    expect(getByLabelText('edit_acs_details')).toBeInTheDocument();
  });
  const saveButton = queryByText('Edit ACS details');
  fireEvent.click(saveButton);
  // can close modal
  await patientlyWaitFor(() => {
    expect(queryAllByText('Edit details')).toHaveLength(1);
  });
  assertNockRequest(acsDetailsScope);
  assertNockRequest(acsEditScope);
  assertNockRequest(acsDetailsScope, done);
  act(done);
});

test('Can show simplified ACS details expandable sections with edit buttons', async (done) => {
  const renderOptions = {
    routerParams: {
      initialEntries: [{ pathname: '/alternate_content_sources/1/details' }],
    },
  };
  const acsDetailsScope = nockInstance
    .get(acsDetailsURL)
    .query(true)
    .reply(200, simplifiedAcsDetails);
  const { queryByText, getByLabelText } =
        renderWithRedux(withACSRoute(<ACSExpandableDetails />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText('test_acs3')).toBeNull();
  expect(queryByText('Hide details')).toBeNull();
  expect(queryByText('Show smart proxies')).toBeNull();
  expect(queryByText('Show URL and subpaths')).toBeNull();
  expect(queryByText('Show credentials')).toBeNull();
  expect(queryByText('Show products')).toBeNull();
  // Assert that the ACS name and expandable sections
  // are now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs3')).toBeInTheDocument();
    expect(queryByText('Hide details')).toBeInTheDocument();
    expect(getByLabelText('edit-details-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Show smart proxies')).toBeInTheDocument();
    expect(getByLabelText('edit-smart-proxies-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Show products')).toBeInTheDocument();
    expect(getByLabelText('edit-products-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Show credentials')).not.toBeInTheDocument();
    expect(queryByText('Show URL and subpaths')).not.toBeInTheDocument();
  });
  assertNockRequest(acsDetailsScope, done);
  act(done);
});

test('Can edit products in a simplified ACS details edit modal', async (done) => {
  const renderOptions = {
    routerParams: {
      initialEntries: [{ pathname: '/alternate_content_sources/1/details' }],
    },
  };
  const acsDetailsScope = nockInstance
    .get(acsDetailsURL)
    .times(2)
    .query(true)
    .reply(200, simplifiedAcsDetails);

  const productsScope = nockInstance
    .get(productsURL)
    .query(true)
    .reply(200, productsList);

  const acsEditScope = nockInstance
    .put(acsDetailsURL)
    .reply(200, acsDetails);

  const { queryByText, getByLabelText, queryAllByText } =
        renderWithRedux(withACSRoute(<ACSExpandableDetails />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText('test_acs3')).toBeNull();
  expect(queryByText('Hide details')).toBeNull();
  expect(queryByText('Show smart proxies')).toBeNull();
  expect(queryByText('Show URL and subpaths')).toBeNull();
  expect(queryByText('Show credentials')).toBeNull();
  expect(queryByText('Show products')).toBeNull();
  // Assert that the ACS name and expandable sections
  // are now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs3')).toBeInTheDocument();
    expect(queryByText('Hide details')).toBeInTheDocument();
    expect(getByLabelText('edit-details-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Show smart proxies')).toBeInTheDocument();
    expect(getByLabelText('edit-smart-proxies-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Show products')).toBeInTheDocument();
    expect(getByLabelText('edit-products-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Show credentials')).not.toBeInTheDocument();
    expect(queryByText('Show URL and subpaths')).not.toBeInTheDocument();
  });
  const editDetails = getByLabelText('edit-products-pencil-edit');
  expect(queryAllByText('Edit products')).toHaveLength(1);
  fireEvent.click(editDetails);
  // Can open modal
  await patientlyWaitFor(() => {
    expect(queryAllByText('Edit products')).toHaveLength(2);
    expect(getByLabelText('edit_acs_details')).toBeInTheDocument();
  });
  const saveButton = queryByText('Edit ACS products');
  fireEvent.click(saveButton);
  // can close modal
  await patientlyWaitFor(() => {
    expect(queryAllByText('Edit products')).toHaveLength(1);
  });
  assertNockRequest(acsDetailsScope);
  assertNockRequest(productsScope);
  assertNockRequest(acsEditScope);
  assertNockRequest(acsDetailsScope, done);
  act(done);
});
