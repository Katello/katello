import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent, within } from 'react-testing-lib-wrapper';
import mockAvailableHostCollections from './availableHostCollections.fixtures.json';
import mockRemovableHostCollections from './removableHostCollections.fixtures.json';
import { REMOVABLE_HOST_COLLECTIONS_KEY } from '../HostCollectionsConstants';
import { assertNockRequest, mockAutocomplete, mockSetting, nockInstance } from '../../../../../../test-utils/nockWrapper';
import katelloApi, { foremanApi } from '../../../../../../services/api';
import { HostCollectionsAddModal, HostCollectionsRemoveModal } from '../HostCollectionsModal';

const renderOptions = () => ({
  apiNamespace: REMOVABLE_HOST_COLLECTIONS_KEY,
  initialState: {
    API: {
      HOST_DETAILS: {
        response: {
          id: 1,
          name: 'test-host',
        },
        status: 'RESOLVED',
      },
    },
  },
});

const availableHostCollections = katelloApi.getApiUrl('/host_collections');
const removableHostCollections = foremanApi.getApiUrl('/host_collections');
const alterHostCollections = foremanApi.getApiUrl('/hosts/1/host_collections');
const autocompleteUrl = '/host_collections/auto_complete_search';
const hostDetailsUrl = '/api/hosts/test-host';

const defaultQuery = {
  host_id: 1,
  per_page: 20,
  page: 1,
};
const defaultQueryWithAvailable = {
  ...defaultQuery,
  available_for: 'host',
};

let firstHostCollection;
let searchDelayScope;
let autoSearchScope;

describe('HostCollectionsAddModal', () => {
  beforeEach(() => {
    const { results } = mockAvailableHostCollections;
    [firstHostCollection] = results;
    searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
    autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', true);
  });

  afterEach(() => {
    assertNockRequest(searchDelayScope);
    assertNockRequest(autoSearchScope);
  });

  test('Calls API with available_for=host on page load', async (done) => {
    const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(availableHostCollections)
      .query(defaultQueryWithAvailable)
      .reply(200, mockAvailableHostCollections);

    const { getAllByText }
       = renderWithRedux(<HostCollectionsAddModal
         isOpen
         closeModal={jest.fn()}
         hostId={1}
         hostName="test-host"
         existingHostCollectionIds={[]}
       />, renderOptions());

    await patientlyWaitFor(() =>
      expect(getAllByText(firstHostCollection.name)[0]).toBeInTheDocument());
    assertNockRequest(autocompleteScope);
    assertNockRequest(scope, done); // Pass jest callback to confirm test is done
  });

  test('Calls alterHostCollections with combined list of existing and new host collections', async (done) => {
    const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(availableHostCollections)
      .query(defaultQueryWithAvailable)
      .reply(200, mockAvailableHostCollections);

    const alterScope = nockInstance
      .put(alterHostCollections, {
        host_collection_ids:
          [...mockRemovableHostCollections.results.map(r => r.id), firstHostCollection.id],
      })
      .reply(200, {});

    const hostDetailsScope = nockInstance
      .get(hostDetailsUrl)
      .reply(200, {});

    const { getByRole, getAllByText }
       = renderWithRedux(<HostCollectionsAddModal
         isOpen
         closeModal={jest.fn()}
         hostId={1}
         hostName="test-host"
         existingHostCollectionIds={mockRemovableHostCollections.results.map(r => r.id)}
       />, renderOptions());

    await patientlyWaitFor(() =>
      expect(getAllByText(firstHostCollection.name)[0]).toBeInTheDocument());
    const checkbox = getByRole('checkbox', { name: 'Select row 0' });
    fireEvent.click(checkbox);
    const addButton = getByRole('button', { name: 'Add' });
    expect(addButton).toHaveAttribute('aria-disabled', 'false');
    fireEvent.click(addButton);

    assertNockRequest(autocompleteScope);
    assertNockRequest(scope);
    assertNockRequest(alterScope);
    assertNockRequest(hostDetailsScope, done);
  });
  test('Host collections whose host limit is exceeded are disabled', async (done) => {
    const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(availableHostCollections)
      .query(defaultQueryWithAvailable)
      .reply(200, mockAvailableHostCollections);

    const { getAllByRole, getAllByText }
       = renderWithRedux(<HostCollectionsAddModal
         isOpen
         closeModal={jest.fn()}
         hostId={1}
         hostName="test-host"
         existingHostCollectionIds={[]}
       />, renderOptions());

    await patientlyWaitFor(() =>
      expect(getAllByText(firstHostCollection.name)[0]).toBeInTheDocument());

    const disabledCheckboxes = getAllByRole('checkbox').filter(c => c.disabled);
    const maxedOutHostCollections = mockAvailableHostCollections.results.filter(r =>
      r.max_hosts === r.total_hosts);
    expect(disabledCheckboxes.length).toBeGreaterThan(0);
    expect(disabledCheckboxes).toHaveLength(maxedOutHostCollections.length);

    assertNockRequest(autocompleteScope);
    assertNockRequest(scope, done); // Pass jest callback to confirm test is done
  });
});

describe('HostCollectionsRemoveModal', () => {
  beforeEach(() => {
    const { results } = mockAvailableHostCollections;
    [firstHostCollection] = results;
    searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
    autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', true);
  });

  afterEach(() => {
    assertNockRequest(searchDelayScope);
    assertNockRequest(autoSearchScope);
  });

  test('Calls API without available_for=host on page load', async (done) => {
    const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(availableHostCollections)
      .query(defaultQuery)
      .reply(200, mockAvailableHostCollections);

    const { getAllByText }
       = renderWithRedux(<HostCollectionsRemoveModal
         isOpen
         closeModal={jest.fn()}
         hostId={1}
         hostName="test-host"
         existingHostCollectionIds={mockRemovableHostCollections.results.map(r => r.id)}
       />, renderOptions());

    // Assert that the packages are now showing on the screen, but wait for them to appear.
    await patientlyWaitFor(() =>
      expect(getAllByText(firstHostCollection.name)[0]).toBeInTheDocument());
    // Assert request was made and completed, see helper function
    assertNockRequest(autocompleteScope);
    assertNockRequest(scope, done); // Pass jest callback to confirm test is done
  });

  test('Calls alterHostCollections with host collections being removed filtered out from the list', async (done) => {
    const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(availableHostCollections)
      .query(defaultQuery)
      .reply(200, mockRemovableHostCollections);

    const alterScope = nockInstance
      .put(alterHostCollections, {
        host_collection_ids:
          mockRemovableHostCollections.results.map(r => r.id).filter(r =>
            r !== mockRemovableHostCollections.results[0].id),
      })
      .reply(200, {});

    const hostDetailsScope = nockInstance // calls host details after successful alter
      .get(hostDetailsUrl)
      .reply(200, {});

    const { getByRole, getAllByText }
       = renderWithRedux(<HostCollectionsRemoveModal
         isOpen
         closeModal={jest.fn()}
         hostId={1}
         hostName="test-host"
         existingHostCollectionIds={mockRemovableHostCollections.results.map(r => r.id)}
       />, renderOptions());

    const [firstRemovableHostCollection] = mockRemovableHostCollections.results;
    await patientlyWaitFor(() =>
      expect(getAllByText(firstRemovableHostCollection.name)[0]).toBeInTheDocument());
    const checkbox = getByRole('checkbox', { name: 'Select row 0' });
    fireEvent.click(checkbox);
    expect(getAllByText('1 selected')).toHaveLength(1);
    const removeButton = getByRole('button', { name: 'Remove' });
    expect(removeButton).toHaveAttribute('aria-disabled', 'false');
    fireEvent.click(removeButton);

    assertNockRequest(autocompleteScope);
    assertNockRequest(scope);
    assertNockRequest(alterScope);
    assertNockRequest(hostDetailsScope, done);
  });
});

