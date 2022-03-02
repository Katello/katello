import React, { useState } from 'react';
import { Modal, Button } from '@patternfly/react-core';
import { useSelector, useDispatch } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import { Thead, Th, Tbody, Tr, Td, TableVariant } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import PropTypes from 'prop-types';
import TableWrapper from '../../../../Table/TableWrapper';
import { useBulkSelect, useSelectionSet } from '../../../../Table/TableHooks';
import { selectAvailableHostCollections, selectAvailableHostCollectionsStatus, selectHostCollections, selectHostCollectionsStatus, selectRemovableHostCollections, selectRemovableHostCollectionsStatus } from './HostCollectionsSelectors';
import hostIdNotReady from '../../HostDetailsActions';
import { alterHostCollections, getHostAvailableHostCollections, getHostRemovableHostCollections } from './HostCollectionsActions';
import { MODAL_TYPES } from './HostCollectionsConstants';

export const HostCollectionsAddModal =
  props => <HostCollectionsModal modalType={MODAL_TYPES.ADD} {...props} />;
export const HostCollectionsRemoveModal =
  props => <HostCollectionsModal modalType={MODAL_TYPES.REMOVE} {...props} />;

export const HostCollectionsModal = ({
  isOpen, closeModal, hostId, hostName, modalType = MODAL_TYPES.ADD, existingHostCollectionIds,
}) => {
  const emptyContentTitle = __('No host collections');
  const emptyContentBody = __('There are no host collections available to add or remove.');
  const emptySearchTitle = __('No matching host collections found');
  const emptySearchBody = __('Try changing your search settings.');

  const columnHeaders = ['', __('Host collection'), __('Capacity'), __('Description')];
  const adding = (modalType === MODAL_TYPES.ADD);

  const response = useSelector(state =>
    (adding ? selectAvailableHostCollections(state) : selectRemovableHostCollections(state))) || {};
  const status = useSelector(state =>
    (adding ?
      selectAvailableHostCollectionsStatus(state) :
      selectRemovableHostCollectionsStatus(state))) || '';
  const dispatch = useDispatch();
  const { results, ...metadata } = response;
  const [suppressFirstFetch, setSuppressFirstFetch] = useState(false);

  const hostLimitNotExceeded = (hc) => {
    const { totalHosts, maxHosts, unlimitedHosts } = propsToCamelCase(hc);
    if (unlimitedHosts) return true;
    return totalHosts < maxHosts;
  };

  const {
    searchQuery,
    updateSearchQuery,
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
  console.log({ selectAll, selectionSet })

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

  const handleModalClose = () => {
    setSuppressFirstFetch(true);
    closeModal();
  };

  const newHostCollectionIds = (hcIds) => {
    console.log({hcIds, selectionSet});
    switch (modalType) {
    case MODAL_TYPES.ADD:
      return [...hcIds, ...selectionSet];
    case MODAL_TYPES.REMOVE:
      return hcIds.filter(id => !selectionSet.has(id));
    default:
      return hcIds;
    }
  };

  const handleModalAction = () => {
    const newIds = newHostCollectionIds(existingHostCollectionIds);
    dispatch(alterHostCollections(hostId, { host_collection_ids: newIds }));
    closeModal();
  };


  const modalActions = ([
    <Button key="add" variant="primary" onClick={handleModalAction} isDisabled={!selectedCount}>
      {adding ? __('Add') : __('Remove')}
    </Button>,
    <Button key="cancel" variant="link" onClick={handleModalClose}>
      Cancel
    </Button>,
  ]);

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleModalClose}
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
          status,
          searchQuery,
          updateSearchQuery,
          selectedCount,
          selectNone,
        }
        }
        additionalListeners={[hostId, modalType]}
        fetchItems={fetchItems}
        searchPlaceholderText={__('Search host collections')}
        autocompleteEndpoint="/host_collections/auto_complete_search"
        variant={TableVariant.compact}
        {...selectAll}
        displaySelectAllCheckbox
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
            return (
              <Tr key={id}>
                <Td
                  select={{
                    disable: adding ? !hostLimitNotExceeded(hostCollection) : false,
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
                  {totalHosts}/{unlimitedHosts ? 'unlimited' : maxHosts}
                </Td>
                <Td>{description}</Td>
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
