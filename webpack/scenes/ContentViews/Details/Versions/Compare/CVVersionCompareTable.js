import React, { useState } from 'react';
import {
  useSelector,
} from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { useTableSort } from 'foremanReact/components/PF4/Helpers/useTableSort';
import { TableVariant, Tr, Th, Tbody, Td, Thead } from '@patternfly/react-table';
import { TableType } from './CVVersionCompareConfig';
import TableWrapper from '../../../../../components/Table/TableWrapper';
import './CVVersionCompare.scss';

const CVVersionCompareTable = ({
  tableConfig: {
    name,
    responseSelector,
    statusSelector,
    autocompleteEndpoint,
    autocompleteQueryParams,
    bookmarkController,
    fetchItems: fetchItemsSorted,
    columnHeaders,
    hideSearch,
    sortConfig,
  }, versionOne, versionTwo, currentActiveKey, selectedViewBy,
}) => {
  const [searchQuery, updateSearchQuery] = useState('');
  const {
    pfSortParams, apiSortParams,
    activeSortColumn, activeSortDirection,
  } = useTableSort({
    allColumns: columnHeaders.map(header => header?.title),
    columnsToSortParams: sortConfig,
    initialSortColumnName: Object.keys(sortConfig)[0],
  });

  const response = useSelector(responseSelector);
  const { results, ...metadata } = response;
  const status = useSelector(statusSelector);
  const fetchItems = params =>
    fetchItemsSorted({
      ...apiSortParams,
      ...params,
    });
  return (
    <TableWrapper
      {...{
        metadata,
        searchQuery,
        updateSearchQuery,
        status,
        autocompleteEndpoint,
        autocompleteQueryParams,
        bookmarkController,
        hideSearch,
      }}
      key={`cvv-comparison-table-${name}`}
      ouiaId={`cvv-comparison-table-${name}`}
      fetchItems={fetchItems}
      additionalListeners={[versionOne, versionTwo, currentActiveKey,
        selectedViewBy, activeSortColumn, activeSortDirection]}
      emptySearchTitle={__(`Your search returned no matching ${name}.`)}
      emptySearchBody={__('Try changing your search criteria.')}
      emptyContentTitle={__(`No matching ${name} found.`)}
      emptyContentBody=""
      variant={TableVariant.compact}
      className="cvv-compare-bordered-table-rows cvv-compare-bordered-table-header"
    >
      <Thead>
        <Tr ouiaId="column-headers">
          {columnHeaders.map(({ title }) =>
            (
              <Th
                modifier="wrap"
                key={`${title}-header`}
                sort={sortConfig[title] ? pfSortParams(title) : undefined}
              >
                {title}
              </Th>
            ))}
        </Tr>
      </Thead>
      <Tbody>
        {results?.map(result =>
          (
            <Tr key={`column-${result.id}`} ouiaId={`column-${result.id}`}>
              {columnHeaders.map(({ getProperty }, colIndex) =>
                (
                  <Td
                  // eslint-disable-next-line react/no-array-index-key
                    key={`cell-${colIndex}`}
                  >
                    {getProperty(result)}
                  </Td>))}
            </Tr>
          ))}
      </Tbody>
    </TableWrapper>
  );
};

CVVersionCompareTable.propTypes = {
  tableConfig: TableType.isRequired,
  versionOne: PropTypes.string.isRequired,
  versionTwo: PropTypes.string.isRequired,
  currentActiveKey: PropTypes.string.isRequired,
  selectedViewBy: PropTypes.string.isRequired,
};

export default CVVersionCompareTable;
