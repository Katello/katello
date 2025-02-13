import React from 'react';
import { Route } from 'react-router-dom';
import { renderWithRedux, patientlyWaitFor, fireEvent, act } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';
import ContentViewDetails from '../ContentViewDetails';
import CONTENT_VIEWS_KEY from '../../ContentViewsConstants';
import cvDetailData from './contentViewRollingDetails.fixtures.json';


const withCVRoute = component => <Route path="/content_views/:id([0-9]+)">{component}</Route>;

const renderOptions = {
  apiNamespace: `${CONTENT_VIEWS_KEY}_1`,
  routerParams: {
    initialEntries: [{ pathname: '/content_views/1', hash: '#/details' }],
    initialIndex: 1,
  },
};

const cvDetailsPath = api.getApiUrl('/content_views/1');

test('Can call API and show details on page load', async (done) => {
  const { label, name, description } = cvDetailData;

  const scope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, cvDetailData);

  const { getByLabelText, queryByLabelText } = renderWithRedux(
    withCVRoute(<ContentViewDetails />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(getByLabelText('name text value')).toHaveTextContent(name);
    expect(getByLabelText('label text value')).toHaveTextContent(label);
    expect(getByLabelText('description text value')).toHaveTextContent(description);
    expect(getByLabelText('a_cv_index')).toBeInTheDocument();
    expect(getByLabelText(`b_${name}`)).toBeInTheDocument();
    expect(getByLabelText('c_details')).toBeInTheDocument();
    expect(queryByLabelText('Import only')).not.toBeInTheDocument();
    expect(queryByLabelText('Generated')).not.toBeInTheDocument();
  });

  assertNockRequest(scope, done);
});

test('Can edit text details such as name', async (done) => {
  const newName = 'agoodrollingname';
  const updatedCVDetails = { ...cvDetailData, name: newName };
  const getscope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, cvDetailData);
  const updatescope = nockInstance
    .put(cvDetailsPath, { include_permissions: true, name: newName })
    .reply(200, updatedCVDetails);
  const afterUpdateScope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, updatedCVDetails);

  const { getByLabelText } = renderWithRedux(
    withCVRoute(<ContentViewDetails />),
    renderOptions,
  );

  const editLabel = 'edit name';
  // Wait for page to load and confirm edit button is present, then click to edit
  await patientlyWaitFor(() => {
    expect(getByLabelText(editLabel)).toBeInTheDocument();
  });
  getByLabelText(editLabel).click();


  const inputLabel = /name text input/;
  await patientlyWaitFor(() => { expect(getByLabelText(inputLabel)).toBeInTheDocument(); });
  fireEvent.change(getByLabelText(inputLabel), { target: { value: newName } });
  getByLabelText('submit name').click();

  // Make sure new name is showing after update
  await patientlyWaitFor(() => {
    expect(getByLabelText('name text value')).toHaveTextContent(newName); assertNockRequest(getscope);
    assertNockRequest(updatescope);
    assertNockRequest(afterUpdateScope, done);
    act(done);
  });
});

test('Page contains Rolling CV type', async (done) => {
  const getscope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, cvDetailData);

  const { queryByText, queryByLabelText } = renderWithRedux(
    withCVRoute(<ContentViewDetails />),
    renderOptions,
  );

  // Wait for page to load
  await patientlyWaitFor(() => {
    expect(queryByText('Content view')).not.toBeInTheDocument();
    expect(queryByText('Rolling content view')).toBeInTheDocument();
    expect(queryByText('Composite content view')).not.toBeInTheDocument();
    expect(queryByText('Versions')).not.toBeInTheDocument();
    expect(queryByText('Filters')).not.toBeInTheDocument();
    expect(queryByText('History')).not.toBeInTheDocument();
    expect(queryByText('Repositories')).toBeInTheDocument();
  });

  // expand actions button
  queryByLabelText('Actions').click();
  // we expect a delete action, but no copy action
  await patientlyWaitFor(() => {
    expect(queryByText('Delete')).toBeVisible();
    expect(queryByText('Copy')).not.toBeInTheDocument();
  });

  assertNockRequest(getscope);
  act(done);
});

test('Page does not containt boolean details such as solve dependencies', async (done) => {
  const updatedCVDetails = { ...cvDetailData };
  const getscope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, cvDetailData);
  const updatescope = nockInstance
    .put(cvDetailsPath, { include_permissions: false, solve_dependencies: false })
    .reply(200, updatedCVDetails);
  const afterUpdateScope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, updatedCVDetails);

  const { queryByLabelText } = renderWithRedux(
    withCVRoute(<ContentViewDetails />),
    renderOptions,
  );

  const checkboxLabel = /solve_dependencies switch/;
  await patientlyWaitFor(() => expect(queryByLabelText(checkboxLabel)).not.toBeInTheDocument());

  const disabledImportLabel = /import_only_switch/;
  expect(queryByLabelText(disabledImportLabel)).not.toBeInTheDocument();

  assertNockRequest(getscope);
  assertNockRequest(updatescope);
  assertNockRequest(afterUpdateScope, done);
  act(done);
});

test('Can link to view tasks', async () => {
  const scope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, cvDetailData);

  const { getByText } = renderWithRedux(
    withCVRoute(<ContentViewDetails />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(getByText(/view tasks/i).closest('a'))
      .toHaveAttribute('href', '/foreman_tasks/tasks?search=resource_type%3D+Katello%3A%3AContentView+resource_id%3D1');
  });

  assertNockRequest(scope);
});

test('Can show import_only and generated when true', async (done) => {
  const updatedCVDetails = { ...cvDetailData };
  updatedCVDetails.generated_for = 'Library';
  updatedCVDetails.import_only = true;

  const scope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, updatedCVDetails);

  const { getByLabelText } = renderWithRedux(
    withCVRoute(<ContentViewDetails />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(getByLabelText('import_only_switch')).toBeInTheDocument();
    expect(getByLabelText('generated_by_export_switch')).toBeInTheDocument();
  });

  assertNockRequest(scope, done);
});
