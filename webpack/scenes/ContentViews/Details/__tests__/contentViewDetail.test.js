import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';

import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';
import ContentViewDetails from '../ContentViewDetails';
import CONTENT_VIEWS_KEY from '../../ContentViewsConstants';

const cvDetailData = require('./contentViewDetails.fixtures.json');

const renderOptions = { namespace: `${CONTENT_VIEWS_KEY}_1` };
const cvDetailsPath = api.getApiUrl('/content_views/1');

test('Can call API and show details on page load', async (done) => {
  const { label, name, description } = cvDetailData;
  const scope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, cvDetailData);

  const { getByLabelText } = renderWithRedux(
    <ContentViewDetails match={{ params: { id: 1 } }} />,
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(getByLabelText('name text value')).toHaveTextContent(name);
    expect(getByLabelText('label text value')).toHaveTextContent(label);
    expect(getByLabelText('description text value')).toHaveTextContent(description);
  });

  assertNockRequest(scope, done);
});

test('Can edit text details such as name', async (done) => {
  const newName = 'agoodname';
  const updatedCVDetails = { ...cvDetailData, name: newName };
  const getscope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, cvDetailData);
  const updatescope = nockInstance
    .put(cvDetailsPath, { name: newName })
    .reply(200, updatedCVDetails);
  const afterUpdateScope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, updatedCVDetails);

  const { getByLabelText } = renderWithRedux(
    <ContentViewDetails match={{ params: { id: 1 } }} />,
    renderOptions,
  );

  const editLabel = 'edit name';
  // Wait for page to load and confirm edit button is present, then click to edit
  await patientlyWaitFor(() => { expect(getByLabelText(editLabel)).toBeInTheDocument(); });
  getByLabelText(editLabel).click();

  const inputLabel = /name text input/;
  await patientlyWaitFor(() => { expect(getByLabelText(inputLabel)).toBeInTheDocument(); });
  fireEvent.change(getByLabelText(inputLabel), { target: { value: newName } });
  getByLabelText('submit name').click();

  // Make sure new name is showing after update
  await patientlyWaitFor(() => { expect(getByLabelText('name text value')).toHaveTextContent(newName); });

  assertNockRequest(getscope);
  assertNockRequest(updatescope);
  assertNockRequest(afterUpdateScope, done);
});

test('Can edit boolean details such as solve dependencies', async (done) => {
  const updatedCVDetails = { ...cvDetailData, solve_dependencies: true };
  const getscope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, cvDetailData);
  const updatescope = nockInstance
    .put(cvDetailsPath, { solve_dependencies: true })
    .reply(200, updatedCVDetails);
  const afterUpdateScope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, updatedCVDetails);

  const { getByLabelText } = renderWithRedux(
    <ContentViewDetails match={{ params: { id: 1 } }} />,
    renderOptions,
  );

  const checkboxLabel = /solve_dependencies switch/;
  await patientlyWaitFor(() => expect(getByLabelText(checkboxLabel)).toBeInTheDocument());
  expect(getByLabelText(checkboxLabel).checked).toBeFalsy();
  fireEvent.click(getByLabelText(checkboxLabel));
  await patientlyWaitFor(() => expect(getByLabelText(checkboxLabel).checked).toBeTruthy());

  assertNockRequest(getscope);
  assertNockRequest(updatescope);
  assertNockRequest(afterUpdateScope, done);
});
