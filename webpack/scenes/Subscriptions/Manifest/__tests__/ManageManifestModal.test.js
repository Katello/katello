import React from 'react';
import { Provider } from 'react-redux';
import { screen, fireEvent } from '@testing-library/react';
import { rtlHelpers } from 'foremanReact/common/testHelpers';
import ManageManifestModal from '../ManageManifestModal';

const { renderWithStore } = rtlHelpers;

const defaultProps = {
  isOpen: true,
  loadManifestHistory: jest.fn(),
  getContentCredentials: jest.fn(),
  loadOrganization: jest.fn(),
  closeModal: jest.fn(),
  upload: jest.fn(),
  refresh: jest.fn(),
  delete: jest.fn(),
  manifestHistory: { loading: false, results: [] },
  organization: {},
  disableManifestActions: false,
  disabledReason: '',
  canImportManifest: true,
  canDeleteManifest: true,
  isManifestImported: false,
  canEditOrganizations: true,
  taskInProgress: false,
  manifestActionStarted: false,
  contentCredentials: [],
};

const tabInteractionProps = {
  canImportManifest: false,
  canDeleteManifest: true,
  canEditOrganizations: true,
  isManifestImported: true,
};

const renderModal = (props = {}) => {
  const {
    store,
    ...renderResult
  } = renderWithStore(<ManageManifestModal {...defaultProps} {...props} />);

  const rerenderModal = (newProps = {}) => {
    const updated = (
      <Provider store={store}>
        <ManageManifestModal {...defaultProps} {...newProps} />
      </Provider>
    );
    renderResult.rerender(updated);
  };

  return { ...renderResult, store, rerenderModal };
};

describe('ManageManifestModal', () => {
  it('shows loading state for manifest history', () => {
    renderModal({
      canImportManifest: false,
      canDeleteManifest: false,
      canEditOrganizations: false,
      manifestHistory: { loading: true, results: [] },
    });

    expect(screen.getByText('Loading')).toBeInTheDocument();
  });

  it('shows empty state when manifest history is empty', () => {
    renderModal({
      canImportManifest: false,
      canDeleteManifest: false,
      canEditOrganizations: false,
    });

    expect(screen.getByText(/There is no manifest history to display/)).toBeInTheDocument();
  });

  it('renders manifest history table columns and rows', () => {
    renderModal({
      canImportManifest: false,
      canDeleteManifest: false,
      canEditOrganizations: false,
      manifestHistory: {
        loading: false,
        results: [
          {
            status: 'success',
            statusMessage: 'Manifest imported',
            created: '2024-01-01 12:00:00',
          },
        ],
      },
    });

    expect(screen.getByText('Status')).toBeInTheDocument();
    expect(screen.getByText('Message')).toBeInTheDocument();
    expect(screen.getByText('Timestamp')).toBeInTheDocument();
    expect(screen.getByText('Manifest imported')).toBeInTheDocument();
  });

  it('resets to the manifest tab when the modal is reopened', () => {
    const { rerenderModal } = renderModal({ ...tabInteractionProps, isOpen: true });

    fireEvent.click(screen.getByText('Manifest History'));
    expect(screen.getByRole('tab', { name: 'Manifest History' })).toHaveAttribute('aria-selected', 'true');

    rerenderModal({ isOpen: false });
    rerenderModal({ isOpen: true });

    expect(screen.getByRole('tab', { name: 'Manifest' })).toHaveAttribute('aria-selected', 'true');
  });

  it('resets to the default tab when the organization changes', () => {
    const { rerenderModal } = renderModal({
      ...tabInteractionProps,
      isOpen: true,
      organization: { id: 1 },
    });

    fireEvent.click(screen.getByText('Manifest History'));

    rerenderModal({
      isOpen: true,
      organization: { id: 2 },
    });

    expect(screen.getByRole('tab', { name: 'Manifest' })).toHaveAttribute('aria-selected', 'true');
  });
});
