import React from 'react';
import { renderWithRedux, act } from 'react-testing-lib-wrapper';
import HOST_DETAILS from '../../../HostDetailsConstants';
import SystemPurposeCard from '../SystemPurposeCard';
import katelloApi, { foremanApi } from '../../../../../../services/api';
import { assertNockRequest, nockInstance } from '../../../../../../test-utils/nockWrapper';

const organizationDetails = katelloApi.getApiUrl('/organizations/1');
const availableReleaseVersions = foremanApi.getApiUrl('/hosts/1/subscriptions/available_release_versions');

const baseHostDetails = {
  id: 1,
  organization_id: 1,
  permissions: {
    edit_hosts: true,
  },
  subscription_facet_attributes: {
    purpose_addons: ['Addon1', 'Addon2'],
    purpose_role: 'Red Hat Enterprise Linux Server',
    purpose_usage: 'Production',
    service_level: 'Premium',
    release_version: '8',
    uuid: '12345',
  },
};

const renderOptions = () => ({
  apiNamespace: HOST_DETAILS,
  initialState: {
    API: {
      HOST_DETAILS: {
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

test('shows system purpose details', async (done) => {
  const orgScope = nockInstance
    .get(organizationDetails)
    .reply(200, {
      id: 1,
    });
  const availableReleaseVersionsScope = nockInstance
    .get(availableReleaseVersions)
    .reply(200, []);

  const { getByText }
    = renderWithRedux(<SystemPurposeCard hostDetails={baseHostDetails} />, renderOptions());
  expect(getByText('Red Hat Enterprise Linux Server')).toBeInTheDocument();
  expect(getByText('Production')).toBeInTheDocument();
  expect(getByText('Premium')).toBeInTheDocument();
  expect(getByText('Addon1')).toBeInTheDocument();
  expect(getByText('Addon2')).toBeInTheDocument();
  expect(getByText('8')).toBeInTheDocument();

  assertNockRequest(orgScope);
  assertNockRequest(availableReleaseVersionsScope, done);
});


test('shows edit button for a user with edit_hosts permission', async (done) => {
  const orgScope = nockInstance
    .get(organizationDetails)
    .reply(200, {
      id: 1,
    });
  const availableReleaseVersionsScope = nockInstance
    .get(availableReleaseVersions)
    .reply(200, []);

  const { queryByText }
    = renderWithRedux(<SystemPurposeCard hostDetails={baseHostDetails} />, renderOptions());
  expect(queryByText('Edit')).toBeInTheDocument();

  assertNockRequest(orgScope);
  assertNockRequest(availableReleaseVersionsScope, done);
});

test('does not show edit button for a user without edit_hosts permission', (done) => {
  const orgScope = nockInstance
    .get(organizationDetails)
    .reply(200, {
      id: 1,
    });
  const availableReleaseVersionsScope = nockInstance
    .get(availableReleaseVersions)
    .reply(200, []);

  const limitedUser = {
    ...baseHostDetails,
    permissions: {
      edit_hosts: false,
    },
  };

  const { queryByText }
    = renderWithRedux(<SystemPurposeCard hostDetails={limitedUser} />);
  expect(queryByText('Edit')).not.toBeInTheDocument();

  assertNockRequest(orgScope);
  assertNockRequest(availableReleaseVersionsScope, done);
  act(done);
});
