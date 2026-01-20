import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';
import FlatpakRemotesForm from '../FlatpakRemoteform';
import api from '../../../../services/api';

const mockFn = jest.fn();
delete window.location;
window.location = { assign: mockFn };

afterEach(() => {
  mockFn.mockClear();
});

const createFlatpakPath = api.getApiUrl('/flatpak_remotes');
const updateFlatpakPath = id => api.getApiUrl(`/flatpak_remotes/${id}`);

const mockRemoteData = {
  id: 1,
  name: 'Test Remote',
  url: 'https://example.com',
  username: 'testuser',
  upstream_password_exists: true,
};

test('Renders FlatpakRemotesForm fields correctly', () => {
  const { getByText } = renderWithRedux(<FlatpakRemotesForm setModalOpen={mockFn} />);
  expect(getByText('Name')).toBeInTheDocument();
  expect(getByText('URL')).toBeInTheDocument();
  expect(getByText('Username')).toBeInTheDocument();
  expect(getByText('Password')).toBeInTheDocument();
});

test('Can save Flatpak remote from form', async (done) => {
  const createScope = nockInstance
    .post(createFlatpakPath, {
      organization_id: 1,
      name: 'New Remote',
      url: 'https://example.com',
      username: 'testuser',
      token: 'password123',
    })
    .reply(201, { id: 2 });

  const { getByLabelText, getByText } = renderWithRedux(<FlatpakRemotesForm
    setModalOpen={mockFn}
  />);
  fireEvent.change(getByLabelText('input_name'), { target: { value: 'New Remote' } });
  fireEvent.change(getByLabelText('input_url'), { target: { value: 'https://example.com' } });
  fireEvent.change(getByLabelText('input_username'), { target: { value: 'testuser' } });
  fireEvent.change(getByLabelText('input_password'), { target: { value: 'password123' } });

  getByText('Create').click();

  await patientlyWaitFor(() => {
    expect(window.location.assign).toHaveBeenCalledWith('/flatpak_remotes/2');
  });

  assertNockRequest(createScope);
  done();
});

test('Can update Flatpak remote from form', async (done) => {
  const updateScope = nockInstance
    .put(updateFlatpakPath(mockRemoteData.id), {
      include_permissions: true,
      name: 'Updated Remote',
      url: 'https://updated.com',
      username: 'updateduser',
    })
    .reply(200);

  const { getByLabelText, getByText } = renderWithRedux(<FlatpakRemotesForm
    setModalOpen={mockFn}
    remoteData={mockRemoteData}
  />);

  fireEvent.change(getByLabelText('input_name'), { target: { value: 'Updated Remote' } });
  fireEvent.change(getByLabelText('input_url'), { target: { value: 'https://updated.com' } });
  fireEvent.change(getByLabelText('input_username'), { target: { value: 'updateduser' } });

  getByText('Update').click();

  await patientlyWaitFor(() => {
    expect(window.location.assign).toHaveBeenCalledWith('/flatpak_remotes/1');
  });

  assertNockRequest(updateScope);
  done();
});

test('Can update Flatpak remote password from placeholder', async (done) => {
  const updateScope = nockInstance
    .put(updateFlatpakPath(mockRemoteData.id), {
      include_permissions: true,
      name: mockRemoteData.name,
      url: mockRemoteData.url,
      username: mockRemoteData.username,
      token: 'newpassword123',
    })
    .reply(200);

  const { getByLabelText, getByText } = renderWithRedux(<FlatpakRemotesForm
    setModalOpen={mockFn}
    remoteData={mockRemoteData}
  />);

  // Simulate changing the password from the placeholder to a new value
  fireEvent.change(getByLabelText('input_password'), { target: { value: 'newpassword123' } });

  getByText('Update').click();

  await patientlyWaitFor(() => {
    expect(window.location.assign).toHaveBeenCalledWith('/flatpak_remotes/1');
  });

  assertNockRequest(updateScope);
  done();
});
