import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { useSelector } from 'react-redux';
import SubscriptionsPage from '../SubscriptionsPage';
import pingUpstreamSubscriptions from '../UpstreamSubscriptions/UpstreamSubscriptionsActions';

const mockDispatch = jest.fn();
const mockSelectorState = {
  organization: { id: 1, owner_details: { upstreamConsumer: {} } },
  missingPermissionsFromApi: null,
};

jest.mock('react-redux', () => ({
  ...jest.requireActual('react-redux'),
  useDispatch: () => mockDispatch,
  useSelector: jest.fn(),
}));

jest.mock('foremanReact/components/PermissionDenied', () => ({
  __esModule: true,
  default: ({ missingPermissions }) => (
    <div>{`PermissionDenied: ${missingPermissions.join(', ')}`}</div>
  ),
}));
jest.mock('foremanReact/components/ForemanModal', () => (<div>ForemanModal Mock</div>));
jest.mock('../Manifest/', () => ({
  __esModule: true, default: () => <div>ManageManifestModal Mock</div>,
}));
jest.mock('../components/SubscriptionsTable/SubscriptionsTable', () => {
  /* eslint-disable global-require, react/prop-types */
  const MockReact = require('react');
  const MockSubscriptionsTable = ({ customHeader, customToolbar, onApiResponse }) => {
    MockReact.useEffect(() => {
      if (!onApiResponse) return undefined;
      if (mockSelectorState.missingPermissionsFromApi) {
        onApiResponse({
          results: [],
          loading: false,
          missingPermissions: mockSelectorState.missingPermissionsFromApi,
          activePermissions: {},
        });
        return undefined;
      }
      onApiResponse({
        results: [],
        loading: false,
        itemCount: 0,
        page: 1,
        perPage: 20,
        searchIsActive: false,
        activePermissions: {
          can_import_manifest: true,
          can_delete_manifest: true,
          can_manage_subscription_allocations: true,
          can_edit_organizations: true,
        },
      });
      return undefined;
    }, [onApiResponse]);

    return (
      <div>
        {customHeader}
        {customToolbar}
        <div>SubscriptionsTable Mock</div>
      </div>
    );
  };
  /* eslint-enable global-require, react/prop-types */
  return {
    __esModule: true,
    default: MockSubscriptionsTable,
  };
});
jest.mock('../components/SubscriptionsToolbar', () => ({
  __esModule: true, default: () => <div>SubscriptionsToolbar Mock</div>,
}));
jest.mock('foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks', () => {
  const mockPrefs = {
    columns: [],
    hasPreference: false,
    currentUserId: 1,
  };
  return {
    useCurrentUserTablePreferences: jest.fn(() => mockPrefs),
  };
});

const buildReduxState = () => ({
  katello: {
    organization: mockSelectorState.organization,
  },
  intervals: {},
  API: {},
});

describe('subscriptions page', () => {
  beforeEach(() => {
    mockDispatch.mockClear();
    mockSelectorState.organization = { id: 1, owner_details: { upstreamConsumer: {} } };
    mockSelectorState.missingPermissionsFromApi = null;
    useSelector.mockImplementation(selector => selector(buildReduxState()));
  });

  it('should render', () => {
    render(<SubscriptionsPage />);

    expect(screen.getByText('Subscriptions')).toBeInTheDocument();
    expect(screen.getByText('SubscriptionsToolbar Mock')).toBeInTheDocument();
    expect(screen.getByText('SubscriptionsTable Mock')).toBeInTheDocument();
    expect(screen.getByText('ManageManifestModal Mock')).toBeInTheDocument();
  });

  it('should render <PermissionDenied /> when subscription permissions are missing', () => {
    mockSelectorState.missingPermissionsFromApi = ['view_subscriptions'];
    render(<SubscriptionsPage />);

    expect(screen.getByText(/PermissionDenied:/)).toBeInTheDocument();
    expect(screen.getByText(/view_subscriptions/)).toBeInTheDocument();
  });

  it('should render <PermissionDenied /> when organization load fails with 403', () => {
    mockSelectorState.organization = {
      loading: false,
      error: { response: { status: 403 } },
    };
    render(<SubscriptionsPage />);

    expect(screen.getByText(/PermissionDenied:/)).toBeInTheDocument();
    expect(screen.getByText(/You do not have permission to view this organization/)).toBeInTheDocument();
  });

  it('should render <PermissionDenied /> when organization load fails with 404', () => {
    mockSelectorState.organization = {
      loading: false,
      error: { response: { status: 404 } },
    };
    render(<SubscriptionsPage />);

    expect(screen.getByText(/PermissionDenied:/)).toBeInTheDocument();
  });

  it('should not render <PermissionDenied /> when organization is still loading', () => {
    mockSelectorState.organization = {
      loading: true,
      error: { response: { status: 403 } },
    };
    render(<SubscriptionsPage />);

    expect(screen.queryByText(/PermissionDenied:/)).not.toBeInTheDocument();
  });
});
