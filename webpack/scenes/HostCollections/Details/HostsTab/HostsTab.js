import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import {
  Button,
  Card,
  CardBody,
} from '@patternfly/react-core';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import { removeHostsFromCollection, getHostCollection } from '../HostCollectionDetailsActions';
import AddHostsModal from './AddHostsModal';

const HostsTab = ({ hostCollectionId }) => {
  const dispatch = useDispatch();
  const [selectedHosts, setSelectedHosts] = useState([]);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  const columns = {
    name: {
      title: __('Name'),
      wrapper: ({ id, name }) => (
        <a href={urlBuilder('hosts', '', id)}>{name}</a>
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

  const handleRemoveSelected = () => {
    if (selectedHosts.length === 0) return;

    const hostIds = selectedHosts.map(host => host.id);
    dispatch(removeHostsFromCollection(hostCollectionId, hostIds, () => {
      setSelectedHosts([]);
      dispatch(getHostCollection(hostCollectionId));
    }));
  };

  const actionButtons = [
    <Button
      key="add-hosts"
      variant="secondary"
      onClick={() => setIsAddModalOpen(true)}
      ouiaId="add-hosts-button"
    >
      {__('Add Hosts')}
    </Button>,
    <Button
      key="remove-selected"
      variant="secondary"
      onClick={handleRemoveSelected}
      isDisabled={selectedHosts.length === 0}
      ouiaId="remove-hosts-button"
    >
      {__('Remove Selected')}
    </Button>,
  ];

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
            actionButtons={actionButtons}
            restrictedSearchQuery={restrictedSearchQuery}
            creatable={false}
            selectionEnabled
            onSelect={setSelectedHosts}
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
        }}
      />
    </>
  );
};

HostsTab.propTypes = {
  hostCollectionId: PropTypes.string.isRequired,
};

export default HostsTab;
