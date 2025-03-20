import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';

import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';
import CopyContentViewForm from '../CopyContentViewForm';

import cvCopyData from './contentViewCopyResult.fixtures.json';

const cvId = '1';
const cvCopyPath = api.getApiUrl(`/content_views/${cvId}/copy`);
const setModalOpen = jest.fn();

const copyParams = {
  id: cvId,
  name: 'cv copy',
};

const copiedCVDetails = { ...cvCopyData };

const form = <CopyContentViewForm cvId={cvId} setModalOpen={setModalOpen} />;

test('Can copy content view from form', async (done) => {
  const copyscope = nockInstance
    .post(cvCopyPath, copyParams)
    .reply(201, copiedCVDetails);
  const { queryByText, getByLabelText } = renderWithRedux(form);
  expect(queryByText('Name')).toBeInTheDocument();

  fireEvent.change(getByLabelText('input_name'), { target: { value: 'cv copy' } });

  getByLabelText('copy_content_view').click();
  // Form closes it self on success
  await patientlyWaitFor(() => {
    expect(setModalOpen).toBeCalled();
  });

  assertNockRequest(copyscope);
  done();
});
