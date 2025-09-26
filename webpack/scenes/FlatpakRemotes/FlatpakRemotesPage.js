import React, { useState } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { useDispatch } from 'react-redux';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import {
  useSetParamsAndApiAndSearch,
  useTableIndexAPIResponse,
} from 'foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { truncate } from '../../utils/helpers';
import CreateFlatpakModal from './CreateEdit/CreateFlatpakRemoteModal';
import EditFlatpakModal from './CreateEdit/EditFlatpakRemotesModal';
import { scanFlatpakRemote } from './Details/FlatpakRemoteDetailActions';
import DeleteFlatpakModal from './Delete/DeleteFlatpakModal';

const FlatpakRemotesPage = () => {
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [editingRemoteData, setEditingRemoteData] = useState(null);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [remoteIdToDelete, setRemoteIdToDelete] = useState('');
  const dispatch = useDispatch();

  const apiOptions = {
    key: 'FLATPAK_REMOTES',
  };

  const apiUrl = '/katello/api/v2/flatpak_remotes';

  const apiResponse = useTableIndexAPIResponse({
    apiUrl,
    apiOptions,
  });

  useSetParamsAndApiAndSearch({
    apiOptions,
    setAPIOptions: apiResponse.setAPIOptions,
  });

  const {
    can_edit: canEdit = false,
    can_delete: canDelete = false,
    can_create: canCreate = false,
    has_redhat_flatpak_remote: hasRedhatRemote = false,
  } = apiResponse.response || {};

  const openCreateModal = () => setIsCreateModalOpen(true);

  const columns = {
    name: {
      title: __('Name'),
      isSorted: true,
      wrapper: rowData => (
        <a href={`${urlBuilder('flatpak_remotes', '')}${rowData.id}`}>
          {truncate(rowData.name)}
        </a>
      ),
    },
    url: {
      title: __('URL'),
      isSorted: true,
      wrapper: rowData => (
        <a href={rowData.url} target="_blank" rel="noopener noreferrer">
          {truncate(rowData.url)}
        </a>
      ),
    },
  };

  const rowKebabItems = remote => [
    {
      title: __('Scan'),
      isDisabled: !canEdit,
      onClick: () => { dispatch(scanFlatpakRemote(remote.id)); },
    },
    {
      title: __('Edit'),
      isDisabled: !canEdit,
      onClick: () => {
        setIsEditModalOpen(true);
        setEditingRemoteData(remote);
      },
    },
    {
      title: __('Delete'),
      isDisabled: !canDelete,
      onClick: () => {
        setRemoteIdToDelete(remote.id);
        setIsDeleteModalOpen(true);
      },
    },
  ];

  return (
    <>
      <TableIndexPage
        apiUrl={apiUrl}
        apiOptions={apiOptions}
        header={__('Flatpak Remotes')}
        columns={columns}
        rowKebabItems={rowKebabItems}
        creatable={canCreate}
        customCreateAction={() => openCreateModal}
        controller="/katello/api/v2/flatpak_remotes"
        ouiaId="flatpak-remotes-table"
      />
      <CreateFlatpakModal
        show={isCreateModalOpen}
        setIsOpen={setIsCreateModalOpen}
        hasRedhatRemote={hasRedhatRemote}
      />
      <EditFlatpakModal
        show={isEditModalOpen}
        setIsOpen={setIsEditModalOpen}
        remoteData={editingRemoteData}
      />
      <DeleteFlatpakModal
        isModalOpen={isDeleteModalOpen}
        handleModalToggle={() => setIsDeleteModalOpen(!isDeleteModalOpen)}
        remoteId={remoteIdToDelete}
      />
    </>
  );
};

export default FlatpakRemotesPage;
