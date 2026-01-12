import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import ContainerfileInstallCommandModal from '../PackagesTab/ContainerfileInstallCommandModal';

// Mock the useAPI hook
const mockSetAPIOptions = jest.fn();
const mockUseAPI = jest.fn();

jest.mock('foremanReact/common/hooks/API/APIHooks', () => ({
  useAPI: (...args) => mockUseAPI(...args),
}));

// Mock navigator.clipboard
Object.assign(navigator, {
  clipboard: {
    writeText: jest.fn(),
  },
});

// Mock toast notifications
global.window.tfm = {
  toastNotifications: {
    notify: jest.fn(),
  },
};

const defaultProps = {
  isOpen: true,
  closeModal: jest.fn(),
  hostId: 1,
  searchParams: 'id ^ (1,2)',
  selectedCount: 2,
};

beforeEach(() => {
  jest.clearAllMocks();
  mockUseAPI.mockReturnValue({
    response: null,
    status: 'PENDING',
    setAPIOptions: mockSetAPIOptions,
  });
});

test('Shows command when API succeeds', async () => {
  const commandText = 'RUN dnf install -y package-1.0-1.el8.x86_64';
  mockUseAPI.mockReturnValue({
    response: {
      command: commandText,
      packageCount: 2,
    },
    status: 'RESOLVED',
    setAPIOptions: mockSetAPIOptions,
  });

  // eslint-disable-next-line max-len
  const { getByDisplayValue, queryByText } = renderWithRedux(<ContainerfileInstallCommandModal {...defaultProps} />);

  await patientlyWaitFor(() => {
    expect(queryByText(/Command contains 2 of 2 selected packages/)).toBeInTheDocument();
  });

  expect(getByDisplayValue(commandText)).toBeInTheDocument();
});

test('Shows empty state when no transient packages', async () => {
  mockUseAPI.mockReturnValue({
    response: {
      command: null,
      message: 'No transient packages found in selection',
      packageCount: 0,
    },
    status: 'RESOLVED',
    setAPIOptions: mockSetAPIOptions,
  });

  // eslint-disable-next-line max-len
  const { getByText, queryByText } = renderWithRedux(<ContainerfileInstallCommandModal {...defaultProps} />);

  await patientlyWaitFor(() => {
    expect(getByText('No transient packages found in selection')).toBeInTheDocument();
  });

  // ClipboardCopy should not be present
  expect(queryByText('RUN dnf')).not.toBeInTheDocument();
});

test('Copy button copies command and closes modal', async () => {
  const commandText = 'RUN dnf install -y package-1.0-1.el8.x86_64';
  mockUseAPI.mockReturnValue({
    response: {
      command: commandText,
      packageCount: 1,
    },
    status: 'RESOLVED',
    setAPIOptions: mockSetAPIOptions,
  });

  const closeModal = jest.fn();
  // eslint-disable-next-line max-len
  const { getByRole } = renderWithRedux(<ContainerfileInstallCommandModal {...defaultProps} closeModal={closeModal} />);

  await patientlyWaitFor(() => {
    expect(getByRole('button', { name: 'Copy' })).toBeInTheDocument();
  });

  const copyButton = getByRole('button', { name: 'Copy' });
  fireEvent.click(copyButton);

  await patientlyWaitFor(() => {
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith(commandText);
    expect(closeModal).toHaveBeenCalled();
  });
});

test('Cancel button closes modal', async () => {
  const closeModal = jest.fn();
  // eslint-disable-next-line max-len
  const { getByRole } = renderWithRedux(<ContainerfileInstallCommandModal {...defaultProps} closeModal={closeModal} />);

  await patientlyWaitFor(() => {
    expect(getByRole('button', { name: 'Cancel' })).toBeInTheDocument();
  });

  const cancelButton = getByRole('button', { name: 'Cancel' });
  fireEvent.click(cancelButton);

  expect(closeModal).toHaveBeenCalled();
});

test('Shows error toast on API failure', async () => {
  mockUseAPI.mockReturnValue({
    response: null,
    status: 'ERROR',
    setAPIOptions: mockSetAPIOptions,
  });

  renderWithRedux(<ContainerfileInstallCommandModal {...defaultProps} />);

  await patientlyWaitFor(() => {
    expect(window.tfm.toastNotifications.notify).toHaveBeenCalledWith({
      message: 'Failed to generate Containerfile install command',
      type: 'error',
    });
  });
});

test('Calls API with correct params when modal opens', async () => {
  renderWithRedux(<ContainerfileInstallCommandModal
    isOpen
    closeModal={jest.fn()}
    hostId={123}
    searchParams="id ^ (1,2,3)"
    selectedCount={3}
  />);

  await patientlyWaitFor(() => {
    expect(mockSetAPIOptions).toHaveBeenCalledWith({
      params: {
        search: 'id ^ (1,2,3)',
        include_unknown_persistence: false,
      },
    });
  });

  // Verify API was called with correct method
  expect(mockUseAPI).toHaveBeenCalledWith(
    'get',
    '/api/hosts/123/transient_packages/containerfile_install_command',
  );
});

test('Does not call API when modal is closed', () => {
  mockUseAPI.mockReturnValue({
    response: null,
    status: null,
    setAPIOptions: mockSetAPIOptions,
  });

  renderWithRedux(<ContainerfileInstallCommandModal
    {...defaultProps}
    isOpen={false}
  />);

  // API should be called with null (deactivated)
  expect(mockUseAPI).toHaveBeenCalledWith(
    null,
    '/api/hosts/1/transient_packages/containerfile_install_command',
  );
});

test('Copy button is disabled while loading', async () => {
  mockUseAPI.mockReturnValue({
    response: {
      command: 'RUN dnf install -y package-1.0-1.el8.x86_64',
      packageCount: 1,
    },
    status: 'PENDING',
    setAPIOptions: mockSetAPIOptions,
  });

  const closeModal = jest.fn();
  // eslint-disable-next-line max-len
  const { getByRole } = renderWithRedux(<ContainerfileInstallCommandModal {...defaultProps} closeModal={closeModal} />);

  await patientlyWaitFor(() => {
    const copyButton = getByRole('button', { name: 'Copy' });
    expect(copyButton).toBeDisabled();
  });
});

test('Copy button is disabled when there is no command', async () => {
  mockUseAPI.mockReturnValue({
    response: {
      command: null,
      packageCount: 0,
    },
    status: 'RESOLVED',
    setAPIOptions: mockSetAPIOptions,
  });

  const closeModal = jest.fn();
  // eslint-disable-next-line max-len
  const { getByRole } = renderWithRedux(<ContainerfileInstallCommandModal {...defaultProps} closeModal={closeModal} />);

  await patientlyWaitFor(() => {
    const copyButton = getByRole('button', { name: 'Copy' });
    expect(copyButton).toBeDisabled();
  });
});

test('Toggling switch updates API params', async () => {
  mockUseAPI.mockReturnValue({
    response: {
      command: 'RUN dnf install -y package-1.0-1.el8.x86_64',
      packageCount: 1,
    },
    status: 'RESOLVED',
    setAPIOptions: mockSetAPIOptions,
  });

  // eslint-disable-next-line max-len
  const { getByRole } = renderWithRedux(<ContainerfileInstallCommandModal {...defaultProps} />);

  // Wait for initial render
  await patientlyWaitFor(() => {
    expect(getByRole('checkbox', { name: 'Include packages with unknown persistence' })).toBeInTheDocument();
  });

  // Verify initial API call has include_unknown_persistence: false
  expect(mockSetAPIOptions).toHaveBeenCalledWith({
    params: {
      search: 'id ^ (1,2)',
      include_unknown_persistence: false,
    },
  });

  // Toggle the switch
  const switchElement = getByRole('checkbox', { name: 'Include packages with unknown persistence' });
  fireEvent.click(switchElement);

  // Verify API call was updated with include_unknown_persistence: true
  await patientlyWaitFor(() => {
    expect(mockSetAPIOptions).toHaveBeenCalledWith({
      params: {
        search: 'id ^ (1,2)',
        include_unknown_persistence: true,
      },
    });
  });
});
