import React from 'react';
import { render, screen } from '@testing-library/react';
import ManageManifestModal from '../ManageManifestModal';

jest.mock('foremanReact/components/common/Slot', () => ({
  __esModule: true,
  default: ({ children }) => children,
}));

jest.mock('foremanReact/components/common/EmptyState', () => ({
  __esModule: true,
  default: props => JSON.stringify(props),
}));

jest.mock('../CdnConfigurationTab', () => ({
  __esModule: true,
  default: () => <div>CDN configuration</div>,
}));

jest.mock('../../../components/LoadingState', () => ({
  LoadingState: ({ loading, children }) => (loading ? <div>Loading</div> : children),
}));

const defaultProps = {
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

describe('ManageManifestModal', () => {
  it('shows loading state for manifest history', () => {
    render(
      <ManageManifestModal
        {...defaultProps}
        manifestHistory={{ loading: true, results: [] }}
      />
    );

    expect(screen.getByText('Loading')).toBeInTheDocument();
  });

  it('shows empty state when manifest history is empty', () => {
    render(<ManageManifestModal {...defaultProps} />);

    expect(screen.getByText(/There is no manifest history to display/)).toBeInTheDocument();
  });

  it('renders manifest history table columns and rows', () => {
    render(
      <ManageManifestModal
        {...defaultProps}
        manifestHistory={{
          loading: false,
          results: [
            {
              status: 'success',
              statusMessage: 'Manifest imported',
              created: '2024-01-01 12:00:00',
            },
          ],
        }}
      />
    );

    expect(screen.getByText('Status')).toBeInTheDocument();
    expect(screen.getByText('Message')).toBeInTheDocument();
    expect(screen.getByText('Timestamp')).toBeInTheDocument();
    expect(screen.getByText('Manifest imported')).toBeInTheDocument();
  });
});
