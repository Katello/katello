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
  expect(queryByText('Details')).toBeNull();
  expect(queryByText('Smart proxies')).toBeNull();
  expect(queryByText('URL and subpaths')).toBeNull();
  expect(queryByText('Credentials')).toBeNull();
  // Assert that the ACS name and expandable sections
  // are now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs')).toBeInTheDocument();
    expect(queryByText('Details')).toBeInTheDocument();
    expect(getByLabelText('edit-details-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Smart proxies')).toBeInTheDocument();
    expect(getByLabelText('edit-smart-proxies-pencil-edit')).toBeInTheDocument();
    expect(queryByText('URL and subpaths')).toBeInTheDocument();
    expect(getByLabelText('edit-urls-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Credentials')).toBeInTheDocument();
    expect(getByLabelText('edit-credentials-pencil-edit')).toBeInTheDocument();
  });
  assertNockRequest(acsDetailsScope);
  done();
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
  const {
    queryByText, getByLabelText, queryAllByText, queryByLabelText,
  } =
        renderWithRedux(withACSRoute(<ACSExpandableDetails />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText('test_acs')).toBeNull();
  expect(queryByText('Details')).toBeNull();
  expect(queryByText('Smart proxies')).toBeNull();
  expect(queryByText('URL and subpaths')).toBeNull();
  expect(queryByText('Credentials')).toBeNull();
  // Assert that the ACS name and expandable sections
  // are now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs')).toBeInTheDocument();
    expect(queryByText('Details')).toBeInTheDocument();
    expect(getByLabelText('edit-details-pencil-edit')).toBeInTheDocument();
  });
  const editDetails = getByLabelText('edit-details-pencil-edit');
  fireEvent.click(editDetails);
  // Can open modal
  await patientlyWaitFor(() => {
    expect(queryAllByText('Edit')).toHaveLength(5);
    expect(getByLabelText('edit_acs_details')).toBeInTheDocument();
  });
  const cancelButton = queryByText('Cancel');
  fireEvent.click(cancelButton);
  // can close modal
  await patientlyWaitFor(() => {
    expect(queryByLabelText('edit_acs_details')).not.toBeInTheDocument();
  });
  assertNockRequest(acsDetailsScope);
  done();
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
  expect(queryByText('Details')).toBeNull();
  expect(queryByText('Smart proxies')).toBeNull();
  expect(queryByText('URL and subpaths')).toBeNull();
  expect(queryByText('Credentials')).toBeNull();
  // Assert that the ACS name and expandable sections
  // are now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs')).toBeInTheDocument();
    expect(queryByText('Details')).toBeInTheDocument();
    expect(getByLabelText('edit-details-pencil-edit')).toBeInTheDocument();
  });
  const editDetails = getByLabelText('edit-details-pencil-edit');
  expect(queryAllByText('Edit')).toHaveLength(4);
  fireEvent.click(editDetails);
  // Can open modal
  await patientlyWaitFor(() => {
    expect(getByLabelText('edit_acs_details')).toBeInTheDocument();
  });
  const saveButton = getByLabelText('edit_acs_details');
  fireEvent.click(saveButton);
  // can close modal
  await patientlyWaitFor(() => {
    expect(queryAllByText('Edit')).toHaveLength(4);
  });
  assertNockRequest(acsDetailsScope);
  assertNockRequest(acsEditScope);
  assertNockRequest(acsDetailsScope);
  done();
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
  expect(queryByText('Details')).toBeNull();
  expect(queryByText('Smart proxies')).toBeNull();
  expect(queryByText('URL and subpaths')).toBeNull();
  expect(queryByText('Credentials')).toBeNull();
  expect(queryByText('Products')).toBeNull();
  // Assert that the ACS name and expandable sections
  // are now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs3')).toBeInTheDocument();
    expect(queryByText('Details')).toBeInTheDocument();
    expect(getByLabelText('edit-details-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Smart proxies')).toBeInTheDocument();
    expect(getByLabelText('edit-smart-proxies-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Products')).toBeInTheDocument();
    expect(getByLabelText('edit-products-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Credentials')).not.toBeInTheDocument();
    expect(queryByText('URL and subpaths')).not.toBeInTheDocument();
  });
  assertNockRequest(acsDetailsScope);
  done();
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
  expect(queryByText('Details')).toBeNull();
  expect(queryByText('Smart proxies')).toBeNull();
  expect(queryByText('URL and subpaths')).toBeNull();
  expect(queryByText('Credentials')).toBeNull();
  expect(queryByText('Products')).toBeNull();
  // Assert that the ACS name and expandable sections
  // are now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs3')).toBeInTheDocument();
    expect(queryByText('Details')).toBeInTheDocument();
    expect(getByLabelText('edit-details-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Smart proxies')).toBeInTheDocument();
    expect(getByLabelText('edit-smart-proxies-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Products')).toBeInTheDocument();
    expect(getByLabelText('edit-products-pencil-edit')).toBeInTheDocument();
    expect(queryByText('Credentials')).not.toBeInTheDocument();
    expect(queryByText('URL and subpaths')).not.toBeInTheDocument();
  });
  const editDetails = getByLabelText('edit-products-pencil-edit');
  expect(queryAllByText('Edit')).toHaveLength(3);
  fireEvent.click(editDetails);
  // Can open modal
  await patientlyWaitFor(() => {
    expect(queryAllByText('Edit')).toHaveLength(4);
    expect(getByLabelText('edit-acs-products')).toBeInTheDocument();
  });
  const saveButton = getByLabelText('edit-acs-products');
  fireEvent.click(saveButton);
  // can close modal
  await patientlyWaitFor(() => {
    expect(queryAllByText('Edit')).toHaveLength(3);
  });
  assertNockRequest(acsDetailsScope);
  assertNockRequest(productsScope);
  assertNockRequest(acsEditScope);
  assertNockRequest(acsDetailsScope);
  done();
  act(done);
});
