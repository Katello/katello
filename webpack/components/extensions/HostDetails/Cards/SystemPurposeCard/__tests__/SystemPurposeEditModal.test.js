import React from 'react';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { STATUS } from 'foremanReact/constants';
import { renderWithRedux, patientlyWaitFor, fireEvent, act } from 'react-testing-lib-wrapper';
import HOST_DETAILS from '../../../HostDetailsConstants';
import SystemPurposeEditModal from '../SystemPurposeEditModal';
import * as systemPurposeActions from '../SystemPurposeActions';
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

describe.each(['host', 'ak'])('System purpose editor requests for %s', (type) => {
  const releaseKey = type === 'host' ? 'AVAILABLE_RELEASE_VERSIONS_1' : 'RELEASES_1';
  const releaseUrl = type === 'host' ? availableReleaseVersions : akAvailableReleaseVersions;
  let organizationSpy;
  let releasesSpy;

  beforeEach(() => {
    organizationSpy = jest.spyOn(systemPurposeActions, 'getOrganization');
    const releaseAction = type === 'host'
      ? 'getHostAvailableReleaseVersions' : 'getAKAvailableReleaseVersions';
    releasesSpy = jest.spyOn(systemPurposeActions, releaseAction);
  });

  afterEach(() => {
    organizationSpy.mockRestore();
    releasesSpy.mockRestore();
  });

  const ToggleModal = () => {
    const [isOpen, setIsOpen] = React.useState(false);
    return (
      <>
        <button onClick={() => setIsOpen(true)}>Open editor</button>
        <SystemPurposeEditModal
          {...baseAttributes}
          {...facetAttributes}
          type={type}
          isOpen={isOpen}
          closeModal={() => setIsOpen(false)}
        />
      </>
    );
  };

  test.each([STATUS.PENDING, STATUS.RESOLVED])('Reuses requests with status %s', async (status) => {
    const { store } = renderWithRedux(
      <SystemPurposeEditModal {...baseAttributes} {...facetAttributes} type={type} />,
      {
        initialState: {
          API: {
            ORGANIZATION_1: { status },
            [releaseKey]: { status },
          },
        },
      },
    );

    if (status === STATUS.PENDING) {
      // A request already in progress must not retry if it fails during this opening.
      await act(async () => {
        store.dispatch({
          type: 'ORGANIZATION_1_FAILURE',
          key: 'ORGANIZATION_1',
          response: { message: 'Forbidden' },
        });
        store.dispatch({
          type: `${releaseKey}_FAILURE`,
          key: releaseKey,
          response: { message: 'Forbidden' },
        });
      });
    }

    expect(organizationSpy).not.toHaveBeenCalled();
    expect(releasesSpy).not.toHaveBeenCalled();
  });

  test.each([
    [undefined, 403],
    [STATUS.ERROR, 200],
  ])('Retries only on reopening with initial status %s and retry HTTP %s', async (initialStatus, retryStatus) => {
    const initialAPI = initialStatus ? {
      ORGANIZATION_1: { status: initialStatus },
      [releaseKey]: { status: initialStatus },
    } : {};
    const {
      getByText, getByLabelText, queryByRole, store,
    } = renderWithRedux(<ToggleModal />, { initialState: { API: initialAPI } });

    expect(queryByRole('dialog')).not.toBeInTheDocument();
    expect(organizationSpy).not.toHaveBeenCalled();
    expect(releasesSpy).not.toHaveBeenCalled();

    const scope = nockInstance
      .get(organizationDetails)
      .reply(403, { error: { message: 'Forbidden' } })
      .get(releaseUrl)
      .reply(403, { error: { message: 'Forbidden' } });

    fireEvent.click(getByText('Open editor'));
    await patientlyWaitFor(() => {
      expect(scope.isDone()).toBe(true);
      expect(store.getState().API.ORGANIZATION_1.status).toBe(STATUS.ERROR);
      expect(store.getState().API[releaseKey].status).toBe(STATUS.ERROR);
    });
    expect(organizationSpy).toHaveBeenCalledTimes(1);
    expect(releasesSpy).toHaveBeenCalledTimes(1);

    fireEvent.click(getByText('Cancel'));
    expect(queryByRole('dialog')).not.toBeInTheDocument();
    expect(organizationSpy).toHaveBeenCalledTimes(1);
    expect(releasesSpy).toHaveBeenCalledTimes(1);

    nockInstance
      .get(organizationDetails)
      .reply(retryStatus, {
        id: 1,
        system_purposes: {
          roles: ['Custom organization role'],
          usage: ['Custom organization usage'],
        },
        service_levels: ['Custom organization service level'],
      })
      .get(releaseUrl)
      .reply(retryStatus, { results: ['9.99'] });

    fireEvent.click(getByText('Open editor'));
    const expectedStatus = retryStatus === 200 ? STATUS.RESOLVED : STATUS.ERROR;
    await patientlyWaitFor(() => {
      expect(scope.isDone()).toBe(true);
      expect(store.getState().API.ORGANIZATION_1.status).toBe(expectedStatus);
      expect(store.getState().API[releaseKey].status).toBe(expectedStatus);
    });
    expect(organizationSpy).toHaveBeenCalledTimes(2);
    expect(releasesSpy).toHaveBeenCalledTimes(2);

    if (retryStatus === 200) {
      expect(getByLabelText('Role')).toHaveTextContent('Custom organization role');
      expect(getByLabelText('Usage')).toHaveTextContent('Custom organization usage');
      expect(getByLabelText('SLA')).toHaveTextContent('Custom organization service level');
      expect(getByLabelText('Release version')).toHaveTextContent('9.99');

      fireEvent.click(getByText('Cancel'));
      fireEvent.click(getByText('Open editor'));
      expect(organizationSpy).toHaveBeenCalledTimes(2);
      expect(releasesSpy).toHaveBeenCalledTimes(2);
      expect(getByLabelText('Release version')).toHaveTextContent('9.99');
    }
  });
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
    expect(getByText('8')).toBeInTheDocument();

    assertNockRequest(orgScope);
    assertNockRequest(availableReleaseVersionsScope);
    done();
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
            // we're going to change role from 'Server' to 'Workstation'
            purpose_role: 'Red Hat Enterprise Linux Workstation',
            purpose_usage: 'Production',
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
    await act(async () => {
      fireEvent.click(saveButton);
    });
    await patientlyWaitFor(() => {
      expect(baseAttributes.closeModal).toHaveBeenCalled();
    });

    [orgScope, availableReleaseVersionsScope, hostEditScope].forEach((scope) => {
      assertNockRequest(scope);
    });
    assertNockRequest(hostDetailsScope);
    done();
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
          purpose_role: 'Red Hat Enterprise Linux Workstation',
          purpose_usage: 'Production',
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
    await act(async () => {
      fireEvent.click(saveButton);
    });
    await patientlyWaitFor(() => {
      expect(baseAttributes.closeModal).toHaveBeenCalled();
    });

    [orgScope, availableReleaseVersionsScope, akEditScope].forEach((scope) => {
      assertNockRequest(scope);
    });
    assertNockRequest(akDetailsScope);
    done();
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
    await act(async () => {
      fireEvent.click(releaseVersionDropdown);
    });
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
    await act(async () => {
      fireEvent.click(releaseVersionDropdown);
    });
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
