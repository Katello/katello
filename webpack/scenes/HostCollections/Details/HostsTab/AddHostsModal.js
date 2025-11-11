import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import { useBulkSelect } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import {
  Modal,
  ModalVariant,
  Button,
  ToolbarItem,
} from '@patternfly/react-core';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import SelectAllCheckbox from 'foremanReact/components/PF4/TableIndexPage/Table/SelectAllCheckbox';
import { addHostsToCollection } from '../HostCollectionDetailsActions';

const AddHostsModal = ({
  isOpen, onClose, hostCollectionId, onHostsAdded,
}) => {
  const dispatch = useDispatch();
  const [isAdding, setIsAdding] = useState(false);

  const response = useSelector(state =>
    selectAPIResponse(state, `HOST_COLLECTION_${hostCollectionId}_AVAILABLE_HOSTS`));
  const { results = [], total = 0, per_page: perPage = 20, ...metadata } = response;

  const {
    selectOne,
    isSelected,
    selectedResults,
    selectNone,
    selectAll,
    selectPage,
    selectedCount,
    areAllRowsOnPageSelected,
    areAllRowsSelected,
  } = useBulkSelect({
    results,
    metadata: { ...metadata, total, page: perPage },
  });

  const handleAddHosts = () => {
    if (selectedCount === 0) return;

    setIsAdding(true);
    // Get selected host IDs - works for both individual selections and select-all mode
    const hostIds = selectedResults.length > 0
      ? selectedResults.map(host => host.id)
      : results.filter(host => isSelected(host.id)).map(host => host.id);

    dispatch(addHostsToCollection(
      hostCollectionId,
      hostIds,
      () => {
        setIsAdding(false);
        selectNone();
        if (onHostsAdded) onHostsAdded();
      },
      () => {
        setIsAdding(false);
      },
    ));
  };

  const columns = {
    name: {
      title: __('Name'),
      wrapper: ({ id, name }) => (
        <a href={urlBuilder('hosts', '', id)}>{name}</a>
      ),
      isSorted: true,
    },
    lifecycle_environment_name: {
      title: __('Lifecycle Environment'),
    },
    content_view_name: {
      title: __('Content View'),
    },
  };

  const selectionToolbar = (
    <ToolbarItem key="selectAll">
      <SelectAllCheckbox
        selectAll={selectAll}
        selectPage={selectPage}
        selectNone={selectNone}
        selectedCount={selectedCount}
        pageRowCount={results.length}
        totalCount={total}
        areAllRowsOnPageSelected={areAllRowsOnPageSelected()}
        areAllRowsSelected={areAllRowsSelected()}
      />
    </ToolbarItem>
  );

  const emptyContentTitle = __('No available hosts');
  const emptyContentBody = __('All hosts are already in this collection, or there are no hosts in the organization.');
  const emptySearchTitle = __('No matching hosts found');
  const emptySearchBody = __('Try changing your search criteria.');

  return (
    <Modal
      variant={ModalVariant.large}
      title={__('Add Hosts to Host Collection')}
      isOpen={isOpen}
      onClose={onClose}
      ouiaId="add-hosts-modal"
      actions={[
        <Button
          key="add"
          variant="primary"
          onClick={handleAddHosts}
          isDisabled={selectedCount === 0 || isAdding}
          isLoading={isAdding}
          ouiaId="add-hosts-submit-button"
        >
          {__('Add Selected')}
        </Button>,
        <Button
          key="cancel"
          variant="link"
          onClick={onClose}
          isDisabled={isAdding}
          ouiaId="add-hosts-cancel-button"
        >
          {__('Cancel')}
        </Button>,
      ]}
    >
      <TableIndexPage
        apiUrl="/api/hosts"
        apiOptions={{
          key: `HOST_COLLECTION_${hostCollectionId}_AVAILABLE_HOSTS`,
          params: {
            search: `NOT host_collection_id = ${hostCollectionId}`,
          },
        }}
        header={__('Available Hosts')}
        controller="hosts"
        columns={columns}
        selectionToolbar={selectionToolbar}
        creatable={false}
        showCheckboxes
        selectOne={selectOne}
        isSelected={isSelected}
        emptyContentTitle={emptyContentTitle}
        emptyContentBody={emptyContentBody}
        emptySearchTitle={emptySearchTitle}
        emptySearchBody={emptySearchBody}
      />
    </Modal>
  );
};

AddHostsModal.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  onClose: PropTypes.func.isRequired,
  hostCollectionId: PropTypes.string.isRequired,
  onHostsAdded: PropTypes.func,
};

AddHostsModal.defaultProps = {
  onHostsAdded: null,
};

export default AddHostsModal;
