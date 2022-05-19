import React, { useState, useCallback } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import { Button } from '@patternfly/react-core';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import TableWrapper from '../../../components/Table/TableWrapper';
import {
  selectAlternateContentSources, selectAlternateContentSourcesError,
  selectAlternateContentSourcesStatus,
} from '../ACSSelectors';
import { useTableSort } from '../../../components/Table/TableHooks';
import getAlternateContentSources, { deleteACS, refreshACS } from '../ACSActions';
import ACSCreateWizard from '../Create/ACSCreateWizard';
import LastSync from '../../ContentViews/Details/Repositories/LastSync';

const ACSTable = () => {
  const response = useSelector(selectAlternateContentSources);
  const status = useSelector(selectAlternateContentSourcesStatus);
  const error = useSelector(selectAlternateContentSourcesError);
  const [searchQuery, updateSearchQuery] = useState('');
  const [isCreateWizardOpen, setIsCreateWizardOpen] = useState(false);
  const dispatch = useDispatch();
  const { results, ...metadata } = response;
  const columnHeaders = [
    __('Name'),
    __('Type'),
    __('Last Refresh'),
  ];

  const COLUMNS_TO_SORT_PARAMS = {
    [columnHeaders[0]]: 'name',
    [columnHeaders[1]]: 'alternate_content_source_type',
  };

  const {
    pfSortParams, apiSortParams,
    activeSortColumn, activeSortDirection,
  } = useTableSort({
    allColumns: columnHeaders,
    columnsToSortParams: COLUMNS_TO_SORT_PARAMS,
    initialSortColumnName: 'Name',
  });

  const fetchItems = useCallback(
    params =>
      getAlternateContentSources({
        ...apiSortParams,
        ...params,
      }),
    [apiSortParams],
  );

  const onDelete = (id) => {
    dispatch(deleteACS(id, () =>
      dispatch(getAlternateContentSources())));
  };

  const onRefresh = (id) => {
    dispatch(refreshACS(id, () =>
      dispatch(getAlternateContentSources())));
  };

  const createButtonOnclick = () => {
    setIsCreateWizardOpen(true);
  };

  const rowDropdownItems = ({ id }) => [
    {
      title: __('Delete'),
      ouiaId: `remove-acs-${id}`,
      onClick: () => {
        onDelete(id);
      },
    },
    {
      title: __('Refresh'),
      ouiaId: `remove-acs-${id}`,
      onClick: () => {
        onRefresh(id);
      },
    },
  ];

  const emptyContentTitle = __("You currently don't have any alternate content sources.");
  const emptyContentBody = __('An alternate content source can be added by using the "Add source" button above.');
  const emptySearchTitle = __('No matching alternate content sources found');
  const emptySearchBody = __('Try changing your search settings.');
  /* eslint-disable react/no-array-index-key */
  return (
    <TableWrapper
      {...{
        metadata,
        emptyContentTitle,
        emptyContentBody,
        emptySearchTitle,
        emptySearchBody,
        searchQuery,
        updateSearchQuery,
        error,
        status,
        fetchItems,
      }}
      ouiaId="alternate-content-sources-table"
      variant={TableVariant.compact}
      additionalListeners={[activeSortColumn, activeSortDirection]}
      autocompleteEndpoint="/alternate_content_sources/auto_complete_search"
      actionButtons={
        <>
          <Button ouiaId="create-acs" onClick={createButtonOnclick} variant="primary" aria-label="create_acs">
            {__('Add source')}
          </Button>
          {isCreateWizardOpen &&
            <ACSCreateWizard
              show={isCreateWizardOpen}
              setIsOpen={setIsCreateWizardOpen}
            />
          }
        </>
      }
    >
      <Thead>
        <Tr>
          {columnHeaders.map(col => (
            <Th
              key={col}
              sort={COLUMNS_TO_SORT_PARAMS[col] ? pfSortParams(col) : undefined}
            >
              {col}
            </Th>
          ))}
        </Tr>
      </Thead>
      <Tbody>
        {results?.map((acs, index) => {
          const {
            name,
            alternate_content_source_type: acsType,
            last_refresh: lastTask,
          } = acs;
          const { last_refresh_words: lastRefreshWords, started_at: startedAt } = lastTask ?? {};
          return (
            <Tr key={index}>
              <Td>{name}</Td>
              <Td>{acsType}</Td>
              <Td><LastSync startedAt={startedAt} lastSync={lastTask} lastSyncWords={lastRefreshWords} emptyMessage="N/A" /></Td>
              <Td
                actions={{
                  items: rowDropdownItems(acs),
                }}
              />
            </Tr>
          );
        })
      }
      </Tbody>
    </TableWrapper>
  );
  /* eslint-enable react/no-array-index-key */
};

export default ACSTable;

