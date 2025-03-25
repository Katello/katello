import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { assertNockRequest, nockInstance } from '../../../../test-utils/nockWrapper';
import ActivationKeyDetails from '../ActivationKeyDetails';
import katelloApi from '../../../../services/api/index';

const akDetails = katelloApi.getApiUrl('/activation_keys/1');

const baseAKDetails = {
  id: 1,
  name: 'test',
  description: 'test description',
  unlimited_hosts: false,
  usage_count: 1,
  max_hosts: 4,
};

const renderOptions = {
  initialState: {
    // This is the API state that your tests depend on for their data
    // You can cross reference the needed useSelectors from your tested components
    // with the data found within the redux chrome add-on to help determine this fixture data.
    katello: {
      hostDetails: {},
    },
  },
};

test('Makes API call and displays AK details on screen', async (done) => {
  const akScope = nockInstance
    .get(akDetails)
    .reply(200, baseAKDetails);
  // eslint-disable-next-line max-len
  const { getByText, getByRole } = renderWithRedux(<ActivationKeyDetails match={{ params: { id: '1' } }} />, renderOptions);
  await patientlyWaitFor(() => expect(getByRole('heading', { name: 'test' })).toBeInTheDocument());
  expect(getByText('test description')).toBeInTheDocument();
  expect(getByText('1/4')).toBeInTheDocument();

  assertNockRequest(akScope);
  done();
});

test('Displays placeholder when description is missing', async (done) => {
  const akScope = nockInstance
    .get(akDetails)
    .reply(
      200,
      {
        ...baseAKDetails,
        description: '',
      },
    );
  // eslint-disable-next-line max-len
  const { getByText, getByRole } = renderWithRedux(<ActivationKeyDetails match={{ params: { id: '1' } }} />, renderOptions);
  await patientlyWaitFor(() => expect(getByRole('heading', { name: 'test' })).toBeInTheDocument());
  expect(getByText('No description provided')).toBeInTheDocument();

  assertNockRequest(akScope);
  done();
});

test('Delete menu appears when toggle is clicked', async (done) => {
  const akScope = nockInstance
    .get(akDetails)
    .reply(200, baseAKDetails);
  // eslint-disable-next-line max-len
  const { getByText, getByLabelText } = renderWithRedux(<ActivationKeyDetails match={{ params: { id: '1' } }} />, renderOptions);
  const deleteToggle = getByLabelText('delete-toggle');
  fireEvent.click(deleteToggle);
  await patientlyWaitFor(() => expect(getByText('Delete')).toBeInTheDocument());

  assertNockRequest(akScope);
  done();
});

test('Edit modal appears when button is clicked', async (done) => {
  const akScope = nockInstance
    .get(akDetails)
    .reply(200, baseAKDetails);
  const { getByLabelText, getByText } = renderWithRedux(<ActivationKeyDetails match={{ params: { id: '1' } }} />, renderOptions);
  const editButton = getByLabelText('edit-button');
  fireEvent.click(editButton);
  await patientlyWaitFor(() => expect(getByText('Edit activation key')).toBeInTheDocument());

  assertNockRequest(akScope);
  done();
});

test('Page displays 0 when usage count is null', async (done) => {
  const akScope = nockInstance
    .get(akDetails)
    .reply(
      200,
      {
        ...baseAKDetails,
        usage_count: null,
      },
    );

  const { getByText, getByRole } = renderWithRedux(<ActivationKeyDetails match={{ params: { id: '1' } }} />, renderOptions);
  await patientlyWaitFor(() => expect(getByRole('heading', { name: 'test' })).toBeInTheDocument());
  expect(getByText('0/4')).toBeInTheDocument();

  assertNockRequest(akScope);
  done();
});

test('Delete modal appears when link is clicked', async (done) => {
  const akScope = nockInstance
    .get(akDetails)
    .reply(200, baseAKDetails);
  // eslint-disable-next-line max-len
  const { getByText, getByLabelText } = renderWithRedux(<ActivationKeyDetails match={{ params: { id: '1' } }} />, renderOptions);
  const deleteToggle = getByLabelText('delete-toggle');
  fireEvent.click(deleteToggle);
  await patientlyWaitFor(() => expect(getByText('Delete')).toBeInTheDocument());
  const deleteLink = getByLabelText('delete-link');
  fireEvent.click(deleteLink);
  await patientlyWaitFor(() => expect(getByText('Activation Key will no longer be available for use. This operation cannot be undone.')).toBeInTheDocument());

  assertNockRequest(akScope);
  done();
});
