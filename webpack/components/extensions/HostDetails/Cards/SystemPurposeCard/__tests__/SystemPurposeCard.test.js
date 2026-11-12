import React from 'react';
import { renderWithRedux } from 'react-testing-lib-wrapper';
import HOST_DETAILS from '../../../HostDetailsConstants';
import SystemPurposeCard from '../SystemPurposeCard';
import { ACTIVATION_KEY } from '../../../../../../scenes/ActivationKeys/Details/ActivationKeyConstants';

const baseHostDetails = {
  id: 1,
  organization_id: 1,
  permissions: {
    edit_hosts: true,
  },
  subscription_facet_attributes: {
    purpose_role: 'Red Hat Enterprise Linux Server',
    purpose_usage: 'Production',
    service_level: 'Premium',
    release_version: '8',
    uuid: '12345',
  },
};

const akHostDetails = {
  ...baseHostDetails,
  subscription_facet_attributes: undefined,
  ...baseHostDetails.subscription_facet_attributes,
};

const renderOptions = (apiNamespace = HOST_DETAILS) => ({
  apiNamespace,
  initialState: {
    API: {
      [apiNamespace]: {
        response: {
          id: 1,
          name: 'test-host',
          ...baseHostDetails,
        },
        status: 'RESOLVED',
      },
    },
  },
});

test('shows system purpose details for a host without fetching editor options', () => {
  const { getByText, store }
    = renderWithRedux(<SystemPurposeCard hostDetails={baseHostDetails} />, renderOptions());
  expect(getByText('Red Hat Enterprise Linux Server')).toBeInTheDocument();
  expect(getByText('Production')).toBeInTheDocument();
  expect(getByText('Premium')).toBeInTheDocument();
  expect(getByText('8')).toBeInTheDocument();

  expect(store.getState().API.ORGANIZATION_1).toBeUndefined();
  expect(store.getState().API.AVAILABLE_RELEASE_VERSIONS_1).toBeUndefined();
});

test('shows system purpose details for an activation key', () => {
  const { getByText } = renderWithRedux(
    <SystemPurposeCard akDetails={akHostDetails} />,
    renderOptions(`${ACTIVATION_KEY}_1`),
  );
  expect(getByText('Red Hat Enterprise Linux Server')).toBeInTheDocument();
  expect(getByText('Production')).toBeInTheDocument();
  expect(getByText('Premium')).toBeInTheDocument();
  expect(getByText('8')).toBeInTheDocument();
});


test('shows edit button for a user with edit_hosts permission', () => {
  const { queryByText }
    = renderWithRedux(<SystemPurposeCard hostDetails={baseHostDetails} />, renderOptions());
  expect(queryByText('Edit')).toBeInTheDocument();
});

test('does not show edit button for a user without edit_hosts permission', () => {
  const limitedUser = {
    ...baseHostDetails,
    permissions: {
      edit_hosts: false,
    },
  };

  const { queryByText }
    = renderWithRedux(<SystemPurposeCard hostDetails={limitedUser} />);
  expect(queryByText('Edit')).not.toBeInTheDocument();
});
