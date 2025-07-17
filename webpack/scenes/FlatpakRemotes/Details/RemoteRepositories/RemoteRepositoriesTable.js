import React from 'react';
import PropTypes from 'prop-types';
import { Table, Thead, Th, Tbody, Tr, Td } from '@patternfly/react-table';
import { Button } from '@patternfly/react-core';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import Pagination from 'foremanReact/components/Pagination';
import EmptyPage from 'foremanReact/routes/common/EmptyPage';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { useTableSort } from 'foremanReact/components/PF4/Helpers/useTableSort';
import {
  useSetParamsAndApiAndSearch,
  useTableIndexAPIResponse,
} from 'foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks';
import LastSync from '../../../ContentViews/Details/Repositories/LastSync';
import { flatpakRemoteRepositoriesKey } from '../../FlatpakRemotesConstants';

const RemoteRepositoriesTable = ({ frId }) => {
  const columnHeaders = [__('Name'), __('ID'), __('Last mirrored'), __('Mirror')];

  const COLUMNS_TO_SORT_PARAMS = {
    [columnHeaders[0]]: 'name',
    [columnHeaders[1]]: 'id',
  };

  const apiUrl = `/katello/api/v2/flatpak_remotes/${frId}/flatpak_remote_repositories`;
  const apiOptions = { key: flatpakRemoteRepositoriesKey(frId) };

  const defaultParams = { page: 1, per_page: 20 };

  const {
    response: {
      results = [],
      subtotal,
      page,
      per_page: perPage,
      message: error,
    } = {},
    status,
    setAPIOptions,
  } = useTableIndexAPIResponse({ apiUrl, apiOptions, defaultParams });

  const { setParamsAndAPI, params } = useSetParamsAndApiAndSearch({
    defaultParams,
    apiOptions,
    setAPIOptions,
  });

  const onSort = (_event, index, direction) => {
    const sortBy = Object.values(COLUMNS_TO_SORT_PARAMS)[index];
    setParamsAndAPI({
      ...params,
      order: `${sortBy} ${direction}`,
    });
  };

  const { pfSortParams } = useTableSort({
    allColumns: columnHeaders,
    columnsToSortParams: COLUMNS_TO_SORT_PARAMS,
    onSort,
  });

  const onPaginationChange = (newPagination) => {
    setParamsAndAPI({ ...params, ...newPagination });
  };

  return (
    <TableIndexPage
      apiUrl={apiUrl}
      apiOptions={apiOptions}
      creatable={false}
      controller="/katello/api/v2/flatpak_remote_repositories"
    >
      <>
        {results.length === 0 && !error && status === STATUS.PENDING && (
          <EmptyPage message={{ type: 'loading', text: __('Loading...') }} />
        )}
        {results.length === 0 && !error && status === STATUS.RESOLVED && (
          <EmptyPage message={{ type: 'empty' }} />
        )}
        {error && <EmptyPage message={{ type: 'error', text: error }} />}

        {results.length > 0 && (
          <Table variant="compact" ouiaId="remote-repos-table" isStriped>
            <Thead>
              <Tr ouiaId="remoteReposTableHeaderRow">
                {columnHeaders.map(col => (
                  <Th
                    key={col}
                    {...(COLUMNS_TO_SORT_PARAMS[col] ? { sort: pfSortParams(col) } : {})}
                  >
                    {col}
                  </Th>
                ))}
              </Tr>
            </Thead>
            <Tbody>
              {results.map(repo => (
                <Tr key={repo.id} ouiaId={`remote-repo-row-${repo.id}`}>
                  <Td>{repo.name}</Td>
                  <Td>{repo.id}</Td>
                  <Td>
                    <LastSync
                      lastSyncWords={repo.last_mirrored?.last_mirror_words}
                      lastSync={{
                        id: repo.last_mirrored?.mirror_id,
                        result: repo.last_mirrored?.result,
                      }}
                      startedAt={repo.last_mirrored?.started_at}
                      emptyMessage={__('Never')}
                    />
                  </Td>
                  <Td>
                    <Button
                      variant="link"
                      isInline
                      ouiaId={`mirror-button-${repo.id}`}
                    >
                      {__('Mirror')}
                    </Button>
                  </Td>
                </Tr>
              ))}
            </Tbody>
          </Table>
        )}

        {results.length > 0 && (
          <Pagination
            key="remote-repos-pagination"
            page={page}
            perPage={perPage}
            itemCount={subtotal}
            onChange={onPaginationChange}
            updateParamsByUrl
          />
        )}
      </>
    </TableIndexPage>
  );
};

RemoteRepositoriesTable.propTypes = {
  frId: PropTypes.number.isRequired,
};

export default RemoteRepositoriesTable;
