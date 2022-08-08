import React, { useState } from 'react';
import {
  useSelector,
} from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { TableVariant, Tr, Th, Tbody, Td, Thead } from '@patternfly/react-table';
import { TableType } from './CVVersionCompareConfig';
import TableWrapper from '../../../../../components/Table/TableWrapper';

const CVVersionCompareTable = ({
  tableConfig: {
    name,
    responseSelector,
    statusSelector,
    autocompleteEndpoint,
    fetchItems,
    columnHeaders,
    disableSearch,
  }, versionOne, versionTwo, currentActiveKey, selectedViewBy,
}) => {
  const [searchQuery, updateSearchQuery] = useState('');

  const response = useSelector(responseSelector);
  const { results, ...metadata } = response;
  const status = useSelector(statusSelector);
  return (
    <TableWrapper
      {...{
        metadata,
        searchQuery,
        updateSearchQuery,
        status,
        autocompleteEndpoint,
        disableSearch,
      }}
      ouiaId="content-view-version-comparison-table"
      fetchItems={fetchItems}
      additionalListeners={[versionOne, versionTwo, currentActiveKey, selectedViewBy]}
      emptySearchTitle={__(`Your search returned no matching ${name}.`)}
      emptySearchBody={__('Try changing your search criteria.')}
      emptyContentTitle={__(`No matching ${name} found.`)}
      emptyContentBody=""
      variant={TableVariant.compact}
    >
      <Thead>
        <Tr>
          {columnHeaders.map(({ title }) =>
            <Th key={`${title}-header`}>{title}</Th>)}
        </Tr>
      </Thead>
      <Tbody>
        {results?.map(result =>
          (
            <Tr key={`column-${result.id}`}>
              {columnHeaders.map(({ getProperty }, colIndex) =>
                // eslint-disable-next-line react/no-array-index-key
                <Td key={`cell-${colIndex}`}>{getProperty(result)} </Td>)}
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
