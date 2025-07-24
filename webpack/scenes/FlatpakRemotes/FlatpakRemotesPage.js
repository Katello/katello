import React, { useState } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { useDispatch, useSelector } from 'react-redux';
import { Table, Thead, Th, Tbody, Tr, Td } from '@patternfly/react-table';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import {
  useSetParamsAndApiAndSearch,
  useTableIndexAPIResponse,
} from 'foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks';
import { useTableSort } from 'foremanReact/components/PF4/Helpers/useTableSort';
import EmptyPage from 'foremanReact/routes/common/EmptyPage';
import Pagination from 'foremanReact/components/Pagination';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { STATUS } from 'foremanReact/constants';
import { selectFlatpakRemotes, selectFlatpakRemotesError, selectFlatpakRemotesStatus } from './FlatpakRemotesSelectors';
import { getResponseErrorMsgs, truncate } from '../../utils/helpers';
import CreateFlatpakModal from './CreateEdit/CreateFlatpakRemoteModal';
import EditFlatpakModal from './CreateEdit/EditFlatpakRemotesModal';
import { deleteFlatpakRemote, scanFlatpakRemote } from './Details/FlatpakRemoteDetailActions';

const FlatpakRemotesPage = () => {
  const response = useSelector(selectFlatpakRemotes);
  const error = useSelector(selectFlatpakRemotesError);
  const status = useSelector(selectFlatpakRemotesStatus);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isEditModalOpen, setEditModalOpen] = useState(false);
  const [editingRemoteData, setEditingRemoteData] = useState(null);
  const dispatch = useDispatch();
  const {
    results = [],
    subtotal,
    page,
    perPage,
    can_edit: canEdit = false,
    can_delete: canDelete = false,
    can_create: canCreate = false,
  } = response || {};

  const columnHeaders = [__('Name'), __('URL')];
  const COLUMNS_TO_SORT_PARAMS = {
    [columnHeaders[0]]: 'name',
    [columnHeaders[1]]: 'url',
  };

  const apiOptions = {
    key: 'FLATPAK_REMOTES',
  };

  const defaultParams = {
    page: page || 1,
    per_page: perPage || 20,
  };

  const apiUrl = '/katello/api/v2/flatpak_remotes';

  const apiResponse = useTableIndexAPIResponse({
    apiUrl,
    apiOptions,
    defaultParams,
  });

  const {
    setParamsAndAPI,
    params,
  } = useSetParamsAndApiAndSearch({
    defaultParams,
    apiOptions,
    setAPIOptions: apiResponse.setAPIOptions,
  });

  const onSort = (_event, index, direction) => {
    const sortBy = Object.values(COLUMNS_TO_SORT_PARAMS)[index];
    setParamsAndAPI({
      ...params,
      order: `${sortBy} ${direction}`,
    });
  };

  const onPaginationChange = (newPagination) => {
    setParamsAndAPI({
      ...params,
      ...newPagination,
    });
  };

  const { pfSortParams } = useTableSort({
    allColumns: columnHeaders,
    columnsToSortParams: COLUMNS_TO_SORT_PARAMS,
    onSort,
  });

  const openCreateModal = () => setIsModalOpen(true);

  const actionsWithPermissions = remote => [
    { title: __('Scan'), isDisabled: !canEdit, onClick: () => { dispatch(scanFlatpakRemote(remote.id)); } },
    {
      title: __('Edit'),
      isDisabled: !canEdit,
      onClick: () => {
        setEditModalOpen(!isEditModalOpen);
        setEditingRemoteData(remote);
      },
    },
    { title: __('Delete'), isDisabled: !canDelete, onClick: () => { dispatch(deleteFlatpakRemote(remote.id, () => { onPaginationChange(); })); } },
  ];

  return (
    <TableIndexPage
      apiUrl={apiUrl}
      apiOptions={apiOptions}
      header={__('Flatpak Remotes')}
      creatable={canCreate}
      customCreateAction={() => openCreateModal}
      controller="/katello/api/v2/flatpak_remotes"
    >
      <>
        {results.length === 0 && !error && status === STATUS.PENDING && (
          <EmptyPage
            message={{
              type: 'loading',
              text: __('Loading...'),
            }}
          />
        )}
        {results.length === 0 && !error && status === STATUS.RESOLVED && (
          <EmptyPage message={{ type: 'empty' }} />
        )}
        {error && (
          <EmptyPage message={{ type: 'error', text: getResponseErrorMsgs(error?.response) }} />
        )}
        {results.length > 0 && (
          <Table variant="compact" ouiaId="flatpak-remotes-table" isStriped>
            <Thead>
              <Tr ouiaId="fltpakRemotesTableHeaderRow">
                {columnHeaders.map(col => (
                  <Th key={col} sort={pfSortParams(col)}>
                    {col}
                  </Th>
                ))}
                <Th key="action-menu" aria-label="action menu table header" />
              </Tr>
            </Thead>
            <Tbody>
              {results.map((remote) => {
                const {
                  id, name, url,
                } = remote;
                return (
                  <Tr key={id} ouiaId={`flatpak-remote-row-${id}`}>
                    <Td><a href={`${urlBuilder('flatpak_remotes', '')}${id}`}>{truncate(name)}</a></Td>
                    <Td>
                      <a href={url} target="_blank" rel="noopener noreferrer">
                        {truncate(url)}
                      </a>
                    </Td>
                    <Td actions={{ items: actionsWithPermissions(remote) }} />
                  </Tr>
                );
              })}
            </Tbody>
          </Table>
        )}
        {results.length > 0 && (
          <Pagination
            key="table-bottom-pagination"
            page={page}
            perPage={perPage}
            itemCount={subtotal}
            onChange={onPaginationChange}
            updateParamsByUrl
          />
        )}
        <CreateFlatpakModal
          show={isModalOpen}
          setIsOpen={setIsModalOpen}
        />
        <EditFlatpakModal
          show={isEditModalOpen}
          setIsOpen={setEditModalOpen}
          remoteData={editingRemoteData}
        />
      </>
    </TableIndexPage>
  );
};

export default FlatpakRemotesPage;
