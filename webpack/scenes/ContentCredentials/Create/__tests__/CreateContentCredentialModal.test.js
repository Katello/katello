import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { fireEvent, screen } from '@testing-library/react';
import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';
import CreateContentCredentialModal from '../CreateContentCredentialModal';

const contentCredentialsPath = api.getApiUrl('/content_credentials');
const renderOptions = { apiNamespace: 'CONTENT_CREDENTIALS' };

const mockCredentialResponse = {
  id: 1,
  name: 'Test GPG Key',
  content_type: 'gpg_key',
  content: '-----BEGIN PGP PUBLIC KEY BLOCK-----\ntest\n-----END PGP PUBLIC KEY BLOCK-----',
  organization: {
    id: 1,
    name: 'Default Organization',
  },
};

const mockPush = jest.fn();
jest.mock('react-router-dom', () => ({
  ...jest.requireActual('react-router-dom'),
  useHistory: () => ({
    push: mockPush,
  }),
}));

describe('CreateContentCredentialModal', () => {
  const setIsOpen = jest.fn();

  beforeEach(() => {
    setIsOpen.mockClear();
    mockPush.mockClear();
  });

  test('renders modal when show is true', () => {
    renderWithRedux(
      <CreateContentCredentialModal show setIsOpen={setIsOpen} />,
      renderOptions,
    );

    expect(screen.getByText('Create content credential')).toBeInTheDocument();
    expect(screen.getByLabelText('name')).toBeInTheDocument();
    expect(screen.getByLabelText('content_type')).toBeInTheDocument();
    expect(screen.getByLabelText('content')).toBeInTheDocument();
  });

  test('does not render modal when show is false', () => {
    renderWithRedux(
      <CreateContentCredentialModal show={false} setIsOpen={setIsOpen} />,
      renderOptions,
    );

    expect(screen.queryByText('Create content credential')).not.toBeInTheDocument();
  });

  test('calls setIsOpen(false) when modal is closed', () => {
    renderWithRedux(
      <CreateContentCredentialModal show setIsOpen={setIsOpen} />,
      renderOptions,
    );

    const closeButton = screen.getByLabelText('Close');
    fireEvent.click(closeButton);

    expect(setIsOpen).toHaveBeenCalledWith(false);
  });

  test('calls setIsOpen(false) when Cancel button is clicked', () => {
    renderWithRedux(
      <CreateContentCredentialModal show setIsOpen={setIsOpen} />,
      renderOptions,
    );

    const cancelButton = screen.getByText('Cancel');
    fireEvent.click(cancelButton);

    expect(setIsOpen).toHaveBeenCalledWith(false);
  });

  test('Create button is disabled when form is incomplete', () => {
    renderWithRedux(
      <CreateContentCredentialModal show setIsOpen={setIsOpen} />,
      renderOptions,
    );

    const createButton = screen.getByText('Create');
    expect(createButton).toBeDisabled();
  });

  test('Create button is enabled when form is complete', async () => {
    renderWithRedux(
      <CreateContentCredentialModal show setIsOpen={setIsOpen} />,
      renderOptions,
    );

    const nameInput = screen.getByLabelText('name');
    const contentInput = screen.getByLabelText('content');

    fireEvent.change(nameInput, { target: { value: 'Test GPG Key' } });
    fireEvent.change(contentInput, { target: { value: '-----BEGIN PGP PUBLIC KEY BLOCK-----\ntest\n-----END PGP PUBLIC KEY BLOCK-----' } });

    await patientlyWaitFor(() => {
      const createButton = screen.getByText('Create');
      expect(createButton).not.toBeDisabled();
    });
  });

  test('Can submit form with GPG key content', async () => {
    const scope = nockInstance
      .post(contentCredentialsPath)
      .reply(200, mockCredentialResponse);

    renderWithRedux(
      <CreateContentCredentialModal show setIsOpen={setIsOpen} />,
      renderOptions,
    );

    const nameInput = screen.getByLabelText('name');
    const contentInput = screen.getByLabelText('content');
    const typeSelect = screen.getByLabelText('content_type');

    fireEvent.change(nameInput, { target: { value: 'Test GPG Key' } });
    fireEvent.change(typeSelect, { target: { value: 'gpg_key' } });
    fireEvent.change(contentInput, { target: { value: '-----BEGIN PGP PUBLIC KEY BLOCK-----\ntest\n-----END PGP PUBLIC KEY BLOCK-----' } });

    const createButton = screen.getByText('Create');
    fireEvent.click(createButton);

    await patientlyWaitFor(() => {
      assertNockRequest(scope);
      expect(mockPush).toHaveBeenCalledWith('/labs/content_credentials');
    });
  });

  test('Can submit form with Certificate content', async () => {
    const certResponse = {
      ...mockCredentialResponse,
      id: 2,
      name: 'Test Certificate',
      content_type: 'cert',
      content: '-----BEGIN CERTIFICATE-----\ntest\n-----END CERTIFICATE-----',
    };

    const scope = nockInstance
      .post(contentCredentialsPath)
      .reply(200, certResponse);

    renderWithRedux(
      <CreateContentCredentialModal show setIsOpen={setIsOpen} />,
      renderOptions,
    );

    const nameInput = screen.getByLabelText('name');
    const contentInput = screen.getByLabelText('content');
    const typeSelect = screen.getByLabelText('content_type');

    fireEvent.change(nameInput, { target: { value: 'Test Certificate' } });
    fireEvent.change(typeSelect, { target: { value: 'cert' } });
    fireEvent.change(contentInput, { target: { value: '-----BEGIN CERTIFICATE-----\ntest\n-----END CERTIFICATE-----' } });

    const createButton = screen.getByText('Create');
    fireEvent.click(createButton);

    await patientlyWaitFor(() => {
      assertNockRequest(scope);
      expect(mockPush).toHaveBeenCalledWith('/labs/content_credentials');
    });
  });

  test('Disables content textarea when file is selected', async () => {
    renderWithRedux(
      <CreateContentCredentialModal show setIsOpen={setIsOpen} />,
      renderOptions,
    );

    const nameInput = screen.getByLabelText('name');
    const contentInput = screen.getByLabelText('content');
    const fileInput = screen.getByLabelText('file_path');

    fireEvent.change(nameInput, { target: { value: 'Test GPG Key' } });

    expect(contentInput).not.toBeDisabled();

    const file = new File(['test content'], 'test.gpg', { type: 'text/plain' });
    fireEvent.change(fileInput, { target: { files: [file] } });

    await patientlyWaitFor(() => {
      expect(contentInput).toBeDisabled();
    });
  });

  test('Clears file when content is entered', async () => {
    renderWithRedux(
      <CreateContentCredentialModal show setIsOpen={setIsOpen} />,
      renderOptions,
    );

    const nameInput = screen.getByLabelText('name');
    const contentInput = screen.getByLabelText('content');
    const fileInput = screen.getByLabelText('file_path');

    fireEvent.change(nameInput, { target: { value: 'Test GPG Key' } });

    const file = new File(['test content'], 'test.gpg', { type: 'text/plain' });
    fireEvent.change(fileInput, { target: { files: [file] } });

    await patientlyWaitFor(() => {
      expect(contentInput).toBeDisabled();
    });

    fireEvent.change(contentInput, { target: { value: '-----BEGIN PGP PUBLIC KEY BLOCK-----\ntest\n-----END PGP PUBLIC KEY BLOCK-----' } });

    await patientlyWaitFor(() => {
      expect(contentInput).not.toBeDisabled();
      expect(contentInput.value).toBe('-----BEGIN PGP PUBLIC KEY BLOCK-----\ntest\n-----END PGP PUBLIC KEY BLOCK-----');
    });
  });

  test('Shows loading state while submitting', async () => {
    const scope = nockInstance
      .post(contentCredentialsPath)
      .delay(100)
      .reply(200, mockCredentialResponse);

    renderWithRedux(
      <CreateContentCredentialModal show setIsOpen={setIsOpen} />,
      renderOptions,
    );

    const nameInput = screen.getByLabelText('name');
    const contentInput = screen.getByLabelText('content');

    fireEvent.change(nameInput, { target: { value: 'Test GPG Key' } });
    fireEvent.change(contentInput, { target: { value: '-----BEGIN PGP PUBLIC KEY BLOCK-----\ntest\n-----END PGP PUBLIC KEY BLOCK-----' } });

    const createButton = screen.getByText('Create');
    fireEvent.click(createButton);

    expect(createButton).toHaveClass('pf-m-in-progress');

    await patientlyWaitFor(() => {
      assertNockRequest(scope);
    });
  });
});
