/* eslint-disable react/no-array-index-key */
import React, { useState } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import { kebabCase } from 'lodash';
import {
  shallowEqual,
  useSelector,
} from 'react-redux';
import {
  Grid,
  Select,
  SelectOption,
  SelectVariant,
} from '@patternfly/react-core';
import {
  TableVariant,
  Tbody,
  Td,
  Th,
  Thead,
  Tr,
} from '@patternfly/react-table';
import { useUrlParams } from '../../../../../components/Table/TableHooks';
import TableWrapper from '../../../../../components/Table/TableWrapper';
import { TableType } from './ContentViewVersionDetailConfig';

const ContentViewVersionDetailsTable = ({
  tableConfig: {
    name,
    repoType,
    responseSelector,
    statusSelector,
    autocompleteEndpoint,
    fetchItems,
    columnHeaders,
    disableSearch,
    route,
  }, repositories,
}) => {
  const ALL_REPOSITORIES = __('All Repositories');
  const [searchQuery, updateSearchQuery] = useState('');
  const [open, setOpen] = useState(false);
  const { repository_id: urlParamId } = useUrlParams();

  const relevantRepositories = repositories
    .filter(({ content_type: contentType }) => repoType === contentType);

  const selectedList = relevantRepositories.length > 1 ? [
    {
      id: undefined,
      name: ALL_REPOSITORIES,
    },
    ...relevantRepositories] :
    relevantRepositories;

  const presetIndex = selectedList
    .findIndex(({ library_instance_id: id }) =>
      id === Number(urlParamId));
  const [selected, setSelected] = useState(presetIndex ?? 0);

  const response = useSelector(responseSelector, shallowEqual);
  const { results, ...metadata } = response;
  const status = useSelector(statusSelector, shallowEqual);

  const fetchItemsWithRepositoryId = (params) => {
    if (selectedList?.length === 1) return fetchItems(params);
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
        ouiaId={`content-view-version-details-${kebabCase(route)}-table`}
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
            ouiaId="repo-type-selector"
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
          <Tr ouiaId="column-headers">
            {columnHeaders.map(({ title, width }) =>
              <Th width={width} key={`${title}-header`}>{title}</Th>)}
          </Tr>
        </Thead>
        <Tbody>
          {results?.map((result, index) => (
            <Tr key={`column-${index}`} ouiaId={`column-${index}`}>
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
