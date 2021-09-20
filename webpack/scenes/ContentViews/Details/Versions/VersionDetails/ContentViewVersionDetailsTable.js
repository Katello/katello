/* eslint-disable react/no-array-index-key */
import React, { useState } from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import { Grid } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import TableWrapper from '../../../../../components/Table/TableWrapper';
import { TableType } from './ContentViewVersionDetailConfig';

const ContentViewVersionDetailsTable = ({ tableConfig }) => {
  const [searchQuery, updateSearchQuery] = useState('');
  const {
    name,
    responseSelector,
    statusSelector,
    autocompleteEndpoint,
    fetchItems,
    columnHeaders,
    disableSearch,
  } = tableConfig;

  const response = useSelector(responseSelector, shallowEqual);
  const status = useSelector(statusSelector, shallowEqual);

  const { results, ...metadata } = response;

  return (
    <Grid hasGutter>
      <TableWrapper
        {...{
          metadata,
          searchQuery,
          updateSearchQuery,
          status,
          autocompleteEndpoint,
          fetchItems,
          disableSearch,
        }}
        emptySearchTitle={__('Your search returned no matching ') + name}
        emptySearchBody={__('Try changing your search criteria.')}
        emptyContentTitle="" // Not needed, as we are not displaying the tab in this case
        emptyContentBody=""
        variant={TableVariant.compact}
      >
        <Thead>
          <Tr>
            {columnHeaders.map(({ title, width }) =>
              <Th width={width} key={`${title}-header`}>{title}</Th>)}
          </Tr>
        </Thead>
        <Tbody>
          {results?.map((result, index) => (
            <Tr key={`column-${index}`}>
              {columnHeaders.map(({ getProperty }, colIndex) =>
                <Td key={`cell-${colIndex}`}>{getProperty(result)} </Td>)}
            </Tr>
          ))}
        </Tbody>
      </TableWrapper>
    </Grid >
  );
};

ContentViewVersionDetailsTable.propTypes = {
  tableConfig: TableType.isRequired,
};

export default ContentViewVersionDetailsTable;
