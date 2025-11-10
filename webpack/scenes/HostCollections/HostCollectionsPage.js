import React, { useState } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import { HOST_COLLECTIONS_KEY } from './HostCollectionsConstants';
import CreateHostCollectionModal from './Create/CreateHostCollectionModal';
import CopyHostCollectionModal from './Copy/CopyHostCollectionModal';
import DeleteHostCollectionModal from './Delete/DeleteHostCollectionModal';

const HostCollectionsPage = () => {
  const [createModalOpen, setCreateModalOpen] = useState(false);
  const [copyModalOpen, setCopyModalOpen] = useState(false);
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [selectedHostCollection, setSelectedHostCollection] = useState(null);

  const handleCopy = (hostCollection) => {
    setSelectedHostCollection(hostCollection);
    setCopyModalOpen(true);
  };

  const handleDelete = (hostCollection) => {
    setSelectedHostCollection(hostCollection);
    setDeleteModalOpen(true);
  };

  const columns = {
    name: {
      title: __('Name'),
      wrapper: ({ id, name }) => (
        <a href={`/labs/host_collections/${id}`}>{name}</a>
      ),
      isSorted: true,
    },
    total_hosts: {
      title: __('Content Hosts'),
      wrapper: ({ id, total_hosts: totalHosts }) => (
        <a href={`/labs/host_collections/${id}#hosts`}>{totalHosts || 0}</a>
      ),
    },
    max_hosts: {
      title: __('Limit'),
      wrapper: ({ max_hosts: maxHosts, unlimited_hosts: unlimitedHosts }) =>
        (unlimitedHosts ? __('Unlimited') : maxHosts || 0),
    },
  };

  const customActionButtons = [
    {
      title: __('Create host collection'),
      action: { onClick: () => setCreateModalOpen(true) },
    },
  ];

  const rowKebabItems = (hostCollection) => {
    const { id, name, permissions = {} } = hostCollection;
    const actions = [];

    if (permissions.edit_host_collections) {
      actions.push({
        title: __('Copy'),
        onClick: () => handleCopy({ id, name }),
      });
    }

    if (permissions.destroy_host_collections) {
      actions.push({
        title: __('Delete'),
        onClick: () => handleDelete({ id, name }),
      });
    }

    return actions;
  };

  return (
    <>
      <TableIndexPage
        apiUrl="/katello/api/host_collections"
        apiOptions={{ key: HOST_COLLECTIONS_KEY }}
        header={__('Host collections')}
        controller="host_collections"
        columns={columns}
        customActionButtons={customActionButtons}
        rowKebabItems={rowKebabItems}
      />
      <CreateHostCollectionModal
        isOpen={createModalOpen}
        onClose={() => setCreateModalOpen(false)}
      />
      {selectedHostCollection && (
        <>
          <CopyHostCollectionModal
            isOpen={copyModalOpen}
            onClose={() => {
              setCopyModalOpen(false);
              setSelectedHostCollection(null);
            }}
            hostCollection={selectedHostCollection}
          />
          <DeleteHostCollectionModal
            isOpen={deleteModalOpen}
            onClose={() => {
              setDeleteModalOpen(false);
              setSelectedHostCollection(null);
            }}
            hostCollection={selectedHostCollection}
          />
        </>
      )}
    </>
  );
};

export default HostCollectionsPage;
