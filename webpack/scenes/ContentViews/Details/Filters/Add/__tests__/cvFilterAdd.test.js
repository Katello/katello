import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';


import api from '../../../../../../services/api';
import CVFilterAddModal from '../CVFilterAddModal';
import { nockInstance, assertNockRequest } from '../../../../../../test-utils/nockWrapper';

const cvCreateData = require('./cvFilterCreateResult.fixtures.json');

const cvCreateFilterPath = api.getApiUrl('/content_view_filters?content_view_id=5');

const setIsOpen = jest.fn();

const createDetails = {
  name: 'test',
  description: 'Creating filter',
  inclusion: true,
  type: 'rpm',
};

const createdCVDetails = { ...cvCreateData };

const form = <CVFilterAddModal cvId={5} show setIsOpen={setIsOpen} />;

test('Can save content view filter from form', (done) => {
  const createFilterscope = nockInstance
    .post(cvCreateFilterPath, createDetails)
    .reply(201, createdCVDetails);
  const { queryByText, getByLabelText } = renderWithRedux(form);
  expect(queryByText('Description')).toBeInTheDocument();

  fireEvent.change(getByLabelText('input_name'), { target: { value: 'test' } });
  fireEvent.change(getByLabelText('input_description'), { target: { value: 'Creating filter' } });

  fireEvent.submit(getByLabelText('create_filter'));
  assertNockRequest(createFilterscope, done);
});

test('Closes content view filter form upon save', async (done) => {
  const createFilterscope = nockInstance
    .post(cvCreateFilterPath, createDetails)
    .reply(201, createdCVDetails);
  const { queryByText, getByLabelText } = renderWithRedux(form);
  fireEvent.change(getByLabelText('input_name'), { target: { value: 'test' } });
  fireEvent.change(getByLabelText('input_description'), { target: { value: 'Creating filter' } });

  fireEvent.submit(getByLabelText('create_filter'));
  await patientlyWaitFor(() => {
    expect(queryByText('Description')).not.toBeInTheDocument();
  });

  assertNockRequest(createFilterscope, done);
});
