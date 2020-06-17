import React from 'react';
import { renderWithRedux, waitFor, fireEvent } from 'react-testing-lib-wrapper';

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

  await waitFor(() => {
    expect(getByLabelText('text value name')).toHaveTextContent(name);
    expect(getByLabelText('text value label')).toHaveTextContent(label);
    expect(getByLabelText('text value description')).toHaveTextContent(description);
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
  // Wait for page to load and confirm edit button is present
  await waitFor(() => { expect(getByLabelText(editLabel)).toBeInTheDocument(); });

  // Update CV name
  getByLabelText(editLabel).click();
  const textInput = getByLabelText('text input name');
  fireEvent.change(textInput, { target: { value: newName } });
  getByLabelText('submit name').click();

  // Make sure new name is showing after update
  await waitFor(() => { expect(getByLabelText('text value name')).toHaveTextContent(newName); });

  assertNockRequest(getscope);
  assertNockRequest(updatescope);
  assertNockRequest(afterUpdateScope, done);
});

test('Can edit boolean details such as force puppet environment', async (done) => {
  const updatedCVDetails = { ...cvDetailData, force_puppet_environment: true };
  const getscope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, cvDetailData);
  const updatescope = nockInstance
    .put(cvDetailsPath, { force_puppet_environment: true })
    .reply(200, updatedCVDetails);
  const afterUpdateScope = nockInstance
    .get(cvDetailsPath)
    .query(true)
    .reply(200, updatedCVDetails);

  const { getByLabelText } = renderWithRedux(
    <ContentViewDetails match={{ params: { id: 1 } }} />,
    renderOptions,
  );

  const checkboxLabel = 'checkbox-force_puppet_environment';
  await waitFor(() => expect(getByLabelText(checkboxLabel)).toBeInTheDocument());
  expect(getByLabelText(checkboxLabel).checked).toBeFalsy();
  fireEvent.click(getByLabelText(checkboxLabel));
  await waitFor(() => expect(getByLabelText(checkboxLabel).checked).toBeTruthy());

  assertNockRequest(getscope);
  assertNockRequest(updatescope);
  assertNockRequest(afterUpdateScope, done);
});
