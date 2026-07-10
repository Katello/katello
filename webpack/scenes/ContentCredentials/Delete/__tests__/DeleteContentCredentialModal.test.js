import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { fireEvent, screen } from '@testing-library/react';
import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';
import DeleteContentCredentialModal from '../DeleteContentCredentialModal';

const renderOptions = { apiNamespace: 'CONTENT_CREDENTIALS' };

const mockPush = jest.fn();
jest.mock('react-router-dom', () => ({
  ...jest.requireActual('react-router-dom'),
  useHistory: () => ({
    push: mockPush,
  }),
}));

describe('DeleteContentCredentialModal', () => {
  const handleModalToggle = jest.fn();
  const refreshTable = jest.fn();
  const credentialId = 123;
  const credentialName = 'Test GPG Key';

  beforeEach(() => {
    handleModalToggle.mockClear();
    refreshTable.mockClear();
    mockPush.mockClear();
  });

  test('renders modal when isModalOpen is true', () => {
    renderWithRedux(
      <DeleteContentCredentialModal
        isModalOpen
        handleModalToggle={handleModalToggle}
        credentialId={credentialId}
        credentialName={credentialName}
      />,
      renderOptions,
    );

    expect(screen.getByText('Delete content credential?')).toBeInTheDocument();
    expect(screen.getByText('Content credential Test GPG Key will be deleted.')).toBeInTheDocument();
  });

  test('does not render modal when isModalOpen is false', () => {
    renderWithRedux(
      <DeleteContentCredentialModal
        isModalOpen={false}
        handleModalToggle={handleModalToggle}
        credentialId={credentialId}
        credentialName={credentialName}
      />,
      renderOptions,
    );

    expect(screen.queryByText('Delete content credential?')).not.toBeInTheDocument();
  });

  test('calls handleModalToggle when modal is closed', () => {
    renderWithRedux(
      <DeleteContentCredentialModal
        isModalOpen
        handleModalToggle={handleModalToggle}
        credentialId={credentialId}
        credentialName={credentialName}
      />,
      renderOptions,
    );

    const closeButton = screen.getByLabelText('Close');
    fireEvent.click(closeButton);

    expect(handleModalToggle).toHaveBeenCalled();
  });

  test('calls handleModalToggle when Cancel button is clicked', () => {
    renderWithRedux(
      <DeleteContentCredentialModal
        isModalOpen
        handleModalToggle={handleModalToggle}
        credentialId={credentialId}
        credentialName={credentialName}
      />,
      renderOptions,
    );

    const cancelButton = screen.getByText('Cancel');
    fireEvent.click(cancelButton);

    expect(handleModalToggle).toHaveBeenCalled();
  });

  test('Delete button is disabled when credentialId is not provided', () => {
    renderWithRedux(
      <DeleteContentCredentialModal
        isModalOpen
        handleModalToggle={handleModalToggle}
        credentialId={undefined}
        credentialName={credentialName}
      />,
      renderOptions,
    );

    const deleteButton = screen.getByText('Delete');
    expect(deleteButton).toBeDisabled();
  });

  test('Delete button is enabled when credentialId is provided', () => {
    renderWithRedux(
      <DeleteContentCredentialModal
        isModalOpen
        handleModalToggle={handleModalToggle}
        credentialId={credentialId}
        credentialName={credentialName}
      />,
      renderOptions,
    );

    const deleteButton = screen.getByText('Delete');
    expect(deleteButton).not.toBeDisabled();
  });

  test('Successfully deletes content credential and redirects to list page', async () => {
    const deleteUrl = api.getApiUrl(`/content_credentials/${credentialId}`);
    const scope = nockInstance
      .delete(deleteUrl)
      .reply(200, {});

    renderWithRedux(
      <DeleteContentCredentialModal
        isModalOpen
        handleModalToggle={handleModalToggle}
        credentialId={credentialId}
        credentialName={credentialName}
        refreshTable={refreshTable}
      />,
      renderOptions,
    );

    const deleteButton = screen.getByText('Delete');
    fireEvent.click(deleteButton);

    await patientlyWaitFor(() => {
      assertNockRequest(scope);
      expect(handleModalToggle).toHaveBeenCalled();
      expect(refreshTable).toHaveBeenCalled();
      expect(mockPush).toHaveBeenCalledWith('/content_credentials');
    });
  });

  test('Handles delete with numeric credentialId', async () => {
    const numericId = 456;
    const deleteUrl = api.getApiUrl(`/content_credentials/${numericId}`);
    const scope = nockInstance
      .delete(deleteUrl)
      .reply(200, {});

    renderWithRedux(
      <DeleteContentCredentialModal
        isModalOpen
        handleModalToggle={handleModalToggle}
        credentialId={numericId}
        credentialName={credentialName}
      />,
      renderOptions,
    );

    const deleteButton = screen.getByText('Delete');
    fireEvent.click(deleteButton);

    await patientlyWaitFor(() => {
      assertNockRequest(scope);
      expect(handleModalToggle).toHaveBeenCalled();
    });
  });

  test('Handles delete with string credentialId', async () => {
    const stringId = '789';
    const deleteUrl = api.getApiUrl(`/content_credentials/${stringId}`);
    const scope = nockInstance
      .delete(deleteUrl)
      .reply(200, {});

    renderWithRedux(
      <DeleteContentCredentialModal
        isModalOpen
        handleModalToggle={handleModalToggle}
        credentialId={stringId}
        credentialName={credentialName}
      />,
      renderOptions,
    );

    const deleteButton = screen.getByText('Delete');
    fireEvent.click(deleteButton);

    await patientlyWaitFor(() => {
      assertNockRequest(scope);
      expect(handleModalToggle).toHaveBeenCalled();
    });
  });

  test('Displays warning message and exclamation icon', () => {
    renderWithRedux(
      <DeleteContentCredentialModal
        isModalOpen
        handleModalToggle={handleModalToggle}
        credentialId={credentialId}
        credentialName={credentialName}
      />,
      renderOptions,
    );

    expect(screen.getByText('Delete content credential?')).toBeInTheDocument();
    const icons = screen.getAllByRole('img', { hidden: true });
    expect(icons.length).toBeGreaterThan(0);
  });

  test('Does not display credential name when not provided', () => {
    renderWithRedux(
      <DeleteContentCredentialModal
        isModalOpen
        handleModalToggle={handleModalToggle}
        credentialId={credentialId}
        credentialName={undefined}
      />,
      renderOptions,
    );

    expect(screen.queryByText(/Content credential .* will be deleted/)).not.toBeInTheDocument();
  });

  test('Does not attempt delete when credentialId is undefined', () => {
    renderWithRedux(
      <DeleteContentCredentialModal
        isModalOpen
        handleModalToggle={handleModalToggle}
        credentialId={undefined}
        credentialName={credentialName}
        refreshTable={refreshTable}
      />,
      renderOptions,
    );

    const deleteButton = screen.getByText('Delete');
    fireEvent.click(deleteButton);

    expect(handleModalToggle).not.toHaveBeenCalled();
    expect(refreshTable).not.toHaveBeenCalled();
    expect(mockPush).not.toHaveBeenCalled();
  });

  test('Uses default props when not provided', () => {
    renderWithRedux(
      <DeleteContentCredentialModal />,
      renderOptions,
    );

    expect(screen.queryByText('Delete content credential?')).not.toBeInTheDocument();
  });
});
