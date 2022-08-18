import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';

import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';
import CreateContentViewForm from '../CreateContentViewForm';
import cvCreateData from './contentViewCreateResult.fixtures.json';

const cvCreatePath = api.getApiUrl('/content_views');

const setModalOpen = jest.fn();

const createDetails = {
  name: '1232123',
  label: '1232123',
  description: '',
  composite: false,
  solve_dependencies: false,
  auto_publish: false,
  import_only: false,
};

const createdCVDetails = { ...cvCreateData };

const form = <CreateContentViewForm setModalOpen={setModalOpen} />;

test('Can save content view from form', async (done) => {
  const createscope = nockInstance
    .post(cvCreatePath, createDetails)
    .reply(201, createdCVDetails);
  const { queryByText, getByLabelText } = renderWithRedux(form);
  expect(queryByText('Description')).toBeInTheDocument();

  fireEvent.change(getByLabelText('input_name'), { target: { value: '1232123' } });

  await patientlyWaitFor(() => { expect(getByLabelText('input_label')).toHaveAttribute('value', '1232123'); });

  getByLabelText('create_content_view').click();

  assertNockRequest(createscope, done);
});

test('Form closes itself upon save', async (done) => {
  const createscope = nockInstance
    .post(cvCreatePath, createDetails)
    .reply(201, createdCVDetails);
  const { getByText, queryByText, getByLabelText } = renderWithRedux(form);
  expect(getByText('Description')).toBeInTheDocument();
  expect(getByText('Name')).toBeInTheDocument();
  expect(getByText('Label')).toBeInTheDocument();

  fireEvent.change(getByLabelText('input_name'), { target: { value: '1232123' } });

  await patientlyWaitFor(() => { expect(getByLabelText('input_label')).toHaveAttribute('value', '1232123'); });

  getByLabelText('create_content_view').click();
  // Form closes it self on success
  await patientlyWaitFor(() => {
    expect(queryByText('Description')).not.toBeInTheDocument();
  });

  assertNockRequest(createscope, done);
});

test('Displays dependent fields correctly', () => {
  const { getByText, queryByText, getByLabelText } = renderWithRedux(form);
  expect(getByText('Description')).toBeInTheDocument();
  expect(getByText('Name')).toBeInTheDocument();
  expect(getByText('Label')).toBeInTheDocument();
  expect(getByText('Composite content view')).toBeInTheDocument();
  expect(getByText('Content view')).toBeInTheDocument();
  expect(getByText('Solve dependencies')).toBeInTheDocument();
  expect(queryByText('Auto publish')).not.toBeInTheDocument();
  expect(getByText('Import only')).toBeInTheDocument();

  // label auto_set
  fireEvent.change(getByLabelText('input_name'), { target: { value: '123 2123' } });
  expect(getByLabelText('input_label')).toHaveAttribute('value', '123_2123');

  // display Auto Publish when Composite CV
  fireEvent.click(getByLabelText('composite_tile'));
  expect(queryByText('Solve dependencies')).not.toBeInTheDocument();
  expect(getByText('Auto publish')).toBeInTheDocument();
  expect(queryByText('Import only')).not.toBeInTheDocument();

  // display Solve Dependencies when Component CV
  fireEvent.click(getByLabelText('component_tile'));
  expect(getByText('Solve dependencies')).toBeInTheDocument();
  expect(queryByText('Auto publish')).not.toBeInTheDocument();
  expect(getByText('Import only')).toBeInTheDocument();
});

test('Validates label field', () => {
  const { getByText, getByLabelText } = renderWithRedux(form);
  expect(getByText('Label')).toBeInTheDocument();

  fireEvent.change(getByLabelText('input_label'), { target: { value: '123 2123' } });
  expect(getByText('Must be Ascii alphanumeric, \'_\' or \'-\'')).toBeInTheDocument();
});
