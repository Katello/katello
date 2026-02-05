import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import { useBulkSelect } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import { get } from 'foremanReact/redux/API';
import {
  Button,
  Card,
  CardBody,
  ToolbarItem,
} from '@patternfly/react-core';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import SelectAllCheckbox from 'foremanReact/components/PF4/TableIndexPage/Table/SelectAllCheckbox';
import { removeHostsFromCollection, getHostCollection } from '../HostCollectionDetailsActions';
import AddHostsModal from './AddHostsModal';

const HostsTab = ({ hostCollectionId }) => {
  const dispatch = useDispatch();
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  const response = useSelector(state =>
    selectAPIResponse(state, `HOST_COLLECTION_${hostCollectionId}_HOSTS`));
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

  const columns = {
    name: {
      title: __('Name'),
      wrapper: ({ name }) => (
        <a href={`/new/hosts/${name}#/Overview`}>{name}</a>
      ),
      isSorted: true,
    },
    lifecycle_environment: {
      title: __('Lifecycle Environment'),
      wrapper: ({ content_facet_attributes }) => (
        content_facet_attributes?.lifecycle_environment?.name || ''
      ),
    },
    content_view: {
      title: __('Content View'),
      wrapper: ({ content_facet_attributes }) => (
        content_facet_attributes?.content_view?.name || ''
      ),
    },
  };

  // Restrict search to only hosts in this collection
  const restrictedSearchQuery = (userSearch) => {
    const filter = `host_collection_id=${hostCollectionId}`;
    const trimmedSearch = userSearch?.trim() ?? '';
    if (!!trimmedSearch && !trimmedSearch.includes(filter)) {
      return `${filter} and ${trimmedSearch}`;
    }
    return filter;
  };

  const refreshHostsTable = () => {
    dispatch(get({
      key: `HOST_COLLECTION_${hostCollectionId}_HOSTS`,
      url: '/api/hosts?include_permissions=true',
      params: {
        search: restrictedSearchQuery(''),
      },
    }));
  };

  const handleRemoveSelected = () => {
    if (selectedCount === 0) return;

    // Get selected host IDs - works for both individual selections and select-all mode
    const hostIds = selectedResults.length > 0
      ? selectedResults.map(host => host.id)
      : results.filter(host => isSelected(host.id)).map(host => host.id);

    dispatch(removeHostsFromCollection(hostCollectionId, hostIds, () => {
      selectNone();
      dispatch(getHostCollection(hostCollectionId));
      refreshHostsTable();
    }));
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

  const customToolbarItems = (
    <>
      <Button
        key="add-hosts"
        variant="primary"
        onClick={() => setIsAddModalOpen(true)}
        ouiaId="add-hosts-button"
        style={{ marginRight: '8px' }}
      >
        {__('Add Hosts')}
      </Button>
      <Button
        key="remove-selected"
        variant="secondary"
        onClick={handleRemoveSelected}
        isDisabled={selectedCount === 0}
        ouiaId="remove-hosts-button"
      >
        {__('Remove Selected')}
      </Button>
    </>
  );

  const emptyContentTitle = __('No hosts yet');
  const emptyContentBody = __('Add hosts to this host collection using the Add Hosts button.');
  const emptySearchTitle = __('No matching hosts found');
  const emptySearchBody = __('Try changing your search criteria.');

  return (
    <>
      <Card ouiaId="host-collection-hosts-card">
        <CardBody>
          <TableIndexPage
            apiUrl="/api/hosts"
            apiOptions={{
              key: `HOST_COLLECTION_${hostCollectionId}_HOSTS`,
            }}
            header={__('Hosts')}
            controller="hosts"
            columns={columns}
            customToolbarItems={customToolbarItems}
            selectionToolbar={selectionToolbar}
            restrictedSearchQuery={restrictedSearchQuery}
            creatable={false}
            showCheckboxes
            selectOne={selectOne}
            isSelected={isSelected}
            emptyContentTitle={emptyContentTitle}
            emptyContentBody={emptyContentBody}
            emptySearchTitle={emptySearchTitle}
            emptySearchBody={emptySearchBody}
          />
        </CardBody>
      </Card>
      <AddHostsModal
        isOpen={isAddModalOpen}
        onClose={() => setIsAddModalOpen(false)}
        hostCollectionId={hostCollectionId}
        onHostsAdded={() => {
          setIsAddModalOpen(false);
          dispatch(getHostCollection(hostCollectionId));
          refreshHostsTable();
        }}
      />
    </>
  );
};

HostsTab.propTypes = {
  hostCollectionId: PropTypes.string.isRequired,
};

export default HostsTab;
