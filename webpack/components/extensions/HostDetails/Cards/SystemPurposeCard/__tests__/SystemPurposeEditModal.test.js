import React from 'react';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import HOST_DETAILS from '../../../HostDetailsConstants';
import SystemPurposeEditModal from '../SystemPurposeEditModal';
import { assertNockRequest, nockInstance } from '../../../../../../test-utils/nockWrapper';
import katelloApi, { foremanApi } from '../../../../../../services/api';
import { ACTIVATION_KEY } from '../../../../../../scenes/ActivationKeys/Details/ActivationKeyConstants';

const organizationDetails = katelloApi.getApiUrl('/organizations/1');
const availableReleaseVersions = foremanApi.getApiUrl('/hosts/1/subscriptions/available_release_versions');
const akAvailableReleaseVersions = katelloApi.getApiUrl('/activation_keys/1/releases');
const hostEditUrl = foremanApi.getApiUrl('/hosts/1');
const akEditUrl = katelloApi.getApiUrl('/activation_keys/1');
const akDetailsGetUrl = akEditUrl;
const hostDetailsGetUrl = '/api/hosts/test-host';

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
  },
};

const akHostDetails = {
  ...baseHostDetails,
  permissions: {
    edit_activation_keys: true,
  },
  subscription_facet_attributes: undefined,
  ...baseHostDetails.subscription_facet_attributes,
};

const facetAttributes = propsToCamelCase(baseHostDetails.subscription_facet_attributes);
const baseAttributes = {
  name: 'test-host',
  closeModal: jest.fn(),
  isOpen: true,
  orgId: 1,
  id: 1,
};

const renderOptions = (apiNamespace = HOST_DETAILS) => ({
  apiNamespace,
  initialState: {
    API: {
      [apiNamespace]: {
        response: {
          id: 1,
          name: 'test-host',
          ...(apiNamespace === HOST_DETAILS ? baseHostDetails : akHostDetails),
        },
        status: 'RESOLVED',
      },
    },
  },
});

describe('SystemPurposeEditModal', () => {
  test('Shows currently selected attributes as defaults', (done) => {
    const orgScope = nockInstance
      .get(organizationDetails)
      .reply(200, {
        id: 1,
      });
    const availableReleaseVersionsScope = nockInstance
      .get(availableReleaseVersions)
      .reply(200, []);

    const { getByText }
      = renderWithRedux(<SystemPurposeEditModal
        type="host"
        {...baseAttributes}
        {...facetAttributes}
      />, renderOptions());

    expect(getByText('Red Hat Enterprise Linux Server')).toBeInTheDocument();
    expect(getByText('Production')).toBeInTheDocument();
    expect(getByText('Premium')).toBeInTheDocument();
    expect(getByText('Addon1')).toBeInTheDocument();
    expect(getByText('Addon2')).toBeInTheDocument();
    expect(getByText('8')).toBeInTheDocument();

    assertNockRequest(orgScope);
    assertNockRequest(availableReleaseVersionsScope, done);
  });

  test('Shows blank options as (unset)', () => {
    const orgScope = nockInstance
      .get(organizationDetails)
      .reply(200, {
        id: 1,
      });
    const availableReleaseVersionsScope = nockInstance
      .get(availableReleaseVersions)
      .reply(200, []);
    const { getAllByText }
      = renderWithRedux(<SystemPurposeEditModal
        type="host"
        {...
          {
            ...baseAttributes,
            purposeRole: '',
          }}
        {...facetAttributes}
      />, renderOptions());

    expect(getAllByText('(unset)')[0]).toBeVisible();

    assertNockRequest(orgScope);
    assertNockRequest(availableReleaseVersionsScope);
  });
  test('Calls API and changes syspurpose values for host', async (done) => {
    const orgScope = nockInstance
      .get(organizationDetails)
      .reply(200, {
        id: 1,
      });
    const availableReleaseVersionsScope = nockInstance
      .get(availableReleaseVersions)
      .reply(200, []);
    const hostEditScope = nockInstance
      .put(hostEditUrl, {
        id: 1,
        host: {
          subscription_facet_attributes: {
            autoheal: true,
            // we're going to change role from 'Server' to 'Workstation'
            purpose_role: 'Red Hat Enterprise Linux Workstation',
            purpose_usage: 'Production',
            purpose_addons: ['Addon1', 'Addon2'],
            release_version: '8',
            service_level: 'Premium',
          },
        },
      })
      .reply(200);
    const hostDetailsScope = nockInstance
      .get(hostDetailsGetUrl)
      .reply(200);

    const { getByLabelText, getByRole }
      = renderWithRedux(<SystemPurposeEditModal
        type="host"
        {...baseAttributes}
        {...facetAttributes}
      />, renderOptions());

    const saveButton = getByRole('button', { name: 'Save' });
    // Save button should be disabled if no values have been changed
    expect(saveButton).toHaveAttribute('aria-disabled', 'true');

    const roleDropdown = getByLabelText('Role');
    fireEvent.change(roleDropdown, { target: { value: 'Red Hat Enterprise Linux Workstation' } });

    // Save button should now be enabled
    expect(saveButton).toHaveAttribute('aria-disabled', 'false');
    fireEvent.click(saveButton);

    await patientlyWaitFor(() => {
      expect(baseAttributes.closeModal).toHaveBeenCalled();
    });

    [orgScope, availableReleaseVersionsScope, hostEditScope].forEach((scope) => {
      assertNockRequest(scope);
    });
    assertNockRequest(hostDetailsScope, done);
  });
  test('Calls API and changes syspurpose values for activation key', async (done) => {
    const orgScope = nockInstance
      .get(organizationDetails)
      .reply(200, {
        id: 1,
      });
    const availableReleaseVersionsScope = nockInstance
      .get(akAvailableReleaseVersions)
      .reply(200, []);
    const akEditScope = nockInstance
      .put(akEditUrl, {
        id: 1,
        activation_key: {
          // we're going to change role from 'Server' to 'Workstation'
          autoheal: true,
          purpose_role: 'Red Hat Enterprise Linux Workstation',
          purpose_usage: 'Production',
          purpose_addons: ['Addon1', 'Addon2'],
          release_version: '8',
          service_level: 'Premium',
        },
      })
      .reply(200);
    const akDetailsScope = nockInstance
      .get(akDetailsGetUrl)
      .reply(200);

    const { getByLabelText, getByRole }
      = renderWithRedux(<SystemPurposeEditModal
        type="ak"
        {...baseAttributes}
        {...facetAttributes}
      />, renderOptions(ACTIVATION_KEY));

    const saveButton = getByRole('button', { name: 'Save' });
    // Save button should be disabled if no values have been changed
    expect(saveButton).toHaveAttribute('aria-disabled', 'true');

    const roleDropdown = getByLabelText('Role');
    fireEvent.change(roleDropdown, { target: { value: 'Red Hat Enterprise Linux Workstation' } });

    // Save button should now be enabled
    expect(saveButton).toHaveAttribute('aria-disabled', 'false');
    fireEvent.click(saveButton);

    await patientlyWaitFor(() => {
      expect(baseAttributes.closeModal).toHaveBeenCalled();
    });

    [orgScope, availableReleaseVersionsScope, akEditScope].forEach((scope) => {
      assertNockRequest(scope);
    });
    assertNockRequest(akDetailsScope, done);
  });
  test('Retrieves available release versions for host', async (done) => {
    const orgScope = nockInstance
      .get(organizationDetails)
      .reply(200, {
        id: 1,
      });
    const availableReleaseVersionsScope = nockInstance
      .get(availableReleaseVersions)
      .reply(200, { results: ['8', '9'] });

    const { getByLabelText, getByText }
      = renderWithRedux(<SystemPurposeEditModal
        type="host"
        {...baseAttributes}
        {...facetAttributes}
      />, renderOptions());

    const releaseVersionDropdown = getByLabelText('Release version');
    fireEvent.click(releaseVersionDropdown);

    await patientlyWaitFor(() => {
      expect(getByText('8')).toBeInTheDocument();
      expect(getByText('9')).toBeInTheDocument();
    });

    [orgScope, availableReleaseVersionsScope].forEach((scope) => {
      assertNockRequest(scope);
    });
    done();
  });
  test('Retrieves available release versions for activation key', async (done) => {
    const orgScope = nockInstance
      .get(organizationDetails)
      .reply(200, {
        id: 1,
      });
    const availableReleaseVersionsScope = nockInstance
      .get(akAvailableReleaseVersions)
      .reply(200, { results: ['8', '9'] });

    const { getByLabelText, getByText }
      = renderWithRedux(<SystemPurposeEditModal
        type="ak"
        {...baseAttributes}
        {...facetAttributes}
      />, renderOptions(ACTIVATION_KEY));

    const releaseVersionDropdown = getByLabelText('Release version');
    fireEvent.click(releaseVersionDropdown);

    await patientlyWaitFor(() => {
      expect(getByText('8')).toBeInTheDocument();
      expect(getByText('9')).toBeInTheDocument();
    });

    [orgScope, availableReleaseVersionsScope].forEach((scope) => {
      assertNockRequest(scope);
    });
    done();
  });
});
