/* eslint-disable react/no-array-index-key */
import React, { useState, useEffect } from 'react';
import { head } from 'lodash';
import PropTypes from 'prop-types';
import { useSelector, shallowEqual } from 'react-redux';
import { Grid, Select, SelectOption, SelectVariant } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import TableWrapper from '../../../../../components/Table/TableWrapper';
import { TableType } from './ContentViewVersionDetailConfig';

const ContentViewVersionDetailsTable = ({ tableConfig, repositories }) => {
  const ALL_REPOSITORIES = __('All Repositories');
  const [searchQuery, updateSearchQuery] = useState('');
  const [open, setOpen] = useState(false);
  const [selected, setSelected] = useState(0);
  const [selectedList, setSelectedList] = useState([]);
  const {
    name,
    repoType,
    responseSelector,
    statusSelector,
    autocompleteEndpoint,
    fetchItems,
    columnHeaders,
    disableSearch,
  } = tableConfig;

  const response = useSelector(responseSelector, shallowEqual);
  const { results, ...metadata } = response;
  const status = useSelector(statusSelector, shallowEqual);

  useEffect(() => {
    const relevantRepositories = repositories
      .filter(({ content_type: contentType }) => repoType === contentType);

    switch (relevantRepositories.length) {
      case 1:
        setSelected(head(relevantRepositories));
        setSelectedList([...relevantRepositories]);
        break;
      default:
        setSelected(0);
        setSelectedList([{
          id: undefined,
          name: ALL_REPOSITORIES,
        }, ...relevantRepositories]);
        break;
    }
  }, [repositories, ALL_REPOSITORIES, repoType]);

  const fetchItemsWithRepositoryId = (params) => {
    if (selectedList.length === 1) return fetchItems(params);
    return fetchItems({ repository_id: selectedList[selected]?.id, ...params });
  };

  return (
    <Grid hasGutter>
      <TableWrapper
        {...{
          metadata,
          searchQuery,
          updateSearchQuery,
          status,
          autocompleteEndpoint,
          disableSearch,
        }}
        additionalListeners={[selected]}
        fetchItems={fetchItemsWithRepositoryId}
        emptySearchTitle={__('Your search returned no matching ') + name}
        emptySearchBody={__('Try changing your search criteria.')}
        emptyContentTitle={__('No matching ') + name + __(' found.')}
        emptyContentBody=""
        variant={TableVariant.compact}
        actionButtons={
          repoType &&
          <Select
            onToggle={setOpen}
            isOpen={open}
            variant={SelectVariant.single}
            onSelect={(_e, selection) => {
              const index = selectedList
                .findIndex((({ name: repoName }) => repoName === selection));
              setSelected(index || 0);
              setOpen(false);
            }}
            selections={selectedList[selected]?.name}
          >
            {selectedList.map(({ name: repoName }, index) => (
              <SelectOption disabled={selectedList.length === 1} key={index} value={repoName} />
            ))}
          </Select>
        }
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
      </TableWrapper >
    </Grid >
  );
};

ContentViewVersionDetailsTable.propTypes = {
  tableConfig: TableType.isRequired,
  repositories: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    content_type: PropTypes.string,
    label: PropTypes.string,
    library_instance_id: PropTypes.number,
  })).isRequired,
};

export default ContentViewVersionDetailsTable;
