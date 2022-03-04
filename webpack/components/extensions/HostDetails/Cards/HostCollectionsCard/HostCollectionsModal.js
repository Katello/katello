import React, { useState } from 'react';
import { Modal, Button } from '@patternfly/react-core';
import { useSelector, useDispatch } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import { Thead, Th, Tbody, Tr, Td, TableVariant } from '@patternfly/react-table';
import { HOST_DETAILS_KEY } from 'foremanReact/components/HostDetails/consts';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import PropTypes from 'prop-types';
import TableWrapper from '../../../../Table/TableWrapper';
import { useSelectionSet } from '../../../../Table/TableHooks';
import { selectAvailableHostCollections, selectAvailableHostCollectionsStatus, selectRemovableHostCollections, selectRemovableHostCollectionsStatus } from './HostCollectionsSelectors';
import hostIdNotReady from '../../HostDetailsActions';
import { alterHostCollections, getHostAvailableHostCollections, getHostRemovableHostCollections } from './HostCollectionsActions';
import { MODAL_TYPES } from './HostCollectionsConstants';
import { truncate } from '../../../../../utils/helpers';

export const HostCollectionsAddModal =
  props => <HostCollectionsModal modalType={MODAL_TYPES.ADD} {...props} />;
export const HostCollectionsRemoveModal =
  props => <HostCollectionsModal modalType={MODAL_TYPES.REMOVE} {...props} />;

export const HostCollectionsModal = ({
  isOpen, closeModal, hostId, hostName, modalType = MODAL_TYPES.ADD, existingHostCollectionIds,
}) => {
  const emptyContentTitle = __('No host collections');
  const emptyContentBody = __('There are no host collections available to add.');
  const emptySearchTitle = __('No matching host collections found');
  const emptySearchBody = __('Try changing your search settings.');
  const errorSearchTitle = __('Problem searching host collections');

  const columnHeaders = ['', __('Host collection'), __('Capacity'), __('Description')];
  const adding = (modalType === MODAL_TYPES.ADD);

  const response = useSelector(state =>
    (adding ? selectAvailableHostCollections(state) : selectRemovableHostCollections(state))) || {};
  const status = useSelector(state =>
    (adding ?
      selectAvailableHostCollectionsStatus(state) :
      selectRemovableHostCollectionsStatus(state))) || '';
  const dispatch = useDispatch();
  const { results, error: errorSearchBody, ...metadata } = response;
  const [suppressFirstFetch, setSuppressFirstFetch] = useState(false);
  const [searchQuery, updateSearchQuery] = useState('');

  const hostLimitNotExceeded = (hc) => {
    const { totalHosts, maxHosts, unlimitedHosts } = propsToCamelCase(hc);
    if (unlimitedHosts) return true;
    return totalHosts < maxHosts;
  };

  const hostLimitExceeded = hc => !hostLimitNotExceeded(hc);

  const {
    isSelected,
    selectOne,
    selectNone,
    fetchBulkParams,
    isSelectable,
    selectedCount,
    selectedResults,
    selectionSet,
    ...selectAll
  } = useSelectionSet({
    results,
    metadata,
    isSelectable: adding ? hc => hostLimitNotExceeded(hc) : () => true,
  });

  const fetchItems = (params) => {
    if (!hostId) return hostIdNotReady;

    if (results?.length > 0 && suppressFirstFetch) {
      // If the modal has already been opened, no need to re-fetch the data that's already present
      setSuppressFirstFetch(false);
      return { type: 'HOST_COLLECTIONS_NOOP' };
    }
    switch (modalType) {
    case MODAL_TYPES.ADD:
      return getHostAvailableHostCollections({ ...params, host_id: hostId });
    case MODAL_TYPES.REMOVE:
      return getHostRemovableHostCollections({ ...params, host_id: hostId });
    default:
      return { type: 'HOST_COLLECTIONS_NOOP' };
    }
  };

  const handleModalCancel = () => {
    setSuppressFirstFetch(true);
    closeModal();
  };

  const newHostCollectionIds = (hcIds) => {
    const uniq = ids => [...new Set(ids)];
    switch (modalType) {
    case MODAL_TYPES.ADD:
      return uniq([...hcIds, ...selectionSet]);
    case MODAL_TYPES.REMOVE:
      return uniq(hcIds.filter(id => !selectionSet.has(id)));
    default:
      return uniq(hcIds);
    }
  };

  const refreshHostDetails = () => dispatch({
    type: 'API_GET',
    payload: {
      key: HOST_DETAILS_KEY,
      url: `/api/hosts/${hostName}`,
    },
  });

  const handleModalAction = () => {
    const newIds = newHostCollectionIds(existingHostCollectionIds);
    dispatch(alterHostCollections(hostId, { host_collection_ids: newIds }, refreshHostDetails));
    selectNone();
    closeModal();
  };

  const modalActions = ([
    <Button key="add" variant="primary" onClick={handleModalAction} isDisabled={!selectedCount}>
      {adding ? __('Add') : __('Remove')}
    </Button>,
    <Button key="cancel" variant="link" onClick={handleModalCancel}>
      Cancel
    </Button>,
  ]);

  return (
    <Modal
      isOpen={isOpen}
      onClose={closeModal}
      title={adding ? __('Add host to host collections') : __('Remove host from host collections')}
      width="50%"
      actions={modalActions}
      id={adding ? 'add-host-to-host-collections-modal' : 'remove-host-from-host-collections-modal'}
    >
      <FormattedMessage
        className="host-collections-modal-blurb"
        id={adding ? 'add-host-to-host-collections-modal-blurb' : 'remove-host-from-host-collections-modal-blurb'}
        defaultMessage={adding ? __('Select host collection(s) to associate with host {hostName}.') : __('Select host collection(s) to remove from host {hostName}.')}
        values={{
          hostName: <strong>{hostName}</strong>,
        }}
      />
      <TableWrapper
        {...{
          metadata,
          emptyContentTitle,
          emptyContentBody,
          emptySearchTitle,
          emptySearchBody,
          errorSearchTitle,
          errorSearchBody,
          status,
          searchQuery,
          updateSearchQuery,
          selectedCount,
          selectNone,
        }
        }
        additionalListeners={[hostId, modalType, existingHostCollectionIds]}
        fetchItems={fetchItems}
        searchPlaceholderText={__('Search host collections')}
        autocompleteEndpoint="/host_collections/auto_complete_search"
        variant={TableVariant.compact}
        {...selectAll}
        displaySelectAllCheckbox={results?.length > 0}
      >
        <Thead>
          <Tr>
            {columnHeaders.map(col =>
              <Th key={col}>{col}</Th>)}
            <Th />
          </Tr>
        </Thead>
        <Tbody>
          {results?.map((hostCollection, rowIndex) => {
            const {
              id, name, description, maxHosts, unlimitedHosts, totalHosts,
            } = propsToCamelCase(hostCollection);
            const isDisabled = (adding && hostLimitExceeded(hostCollection));
            return (
              <Tr key={id}>
                <Td
                  select={{
                    disable: isDisabled,
                    isSelected: isSelected(id),
                    onSelect: (_event, selected) => selectOne(selected, id, hostCollection),
                    rowIndex,
                    variant: 'checkbox',
                  }}
                />
                <Td>
                  <a href={urlBuilder(`host_collections/${id}`, '')}>{name}</a>
                </Td>
                <Td>
                  {totalHosts}/{unlimitedHosts ? __('unlimited') : maxHosts}
                </Td>
                <Td>{description && truncate(description)}</Td>
              </Tr>
            );
          })
          }
        </Tbody>
      </TableWrapper>
    </Modal>
  );
};

HostCollectionsModal.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  closeModal: PropTypes.func.isRequired,
  hostId: PropTypes.number.isRequired,
  hostName: PropTypes.string.isRequired,
  showKatelloAgent: PropTypes.bool,
  modalType: PropTypes.string.isRequired,
  existingHostCollectionIds: PropTypes.arrayOf(PropTypes.number).isRequired,
};

HostCollectionsModal.defaultProps = {
  showKatelloAgent: false,
};

export default HostCollectionsModal;
