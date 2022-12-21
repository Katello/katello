import React, { useState, useCallback } from 'react';
import { useSelector } from 'react-redux';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import {
  selectRepositoryContentDetails,
  selectRepositoryContentDetailsError,
  selectRepositoryContentDetailsStatus,
} from '../ContentSelectors';
import contentConfig from '../ContentConfig';
import { getRepositoryContentDetails } from '../ContentActions';
import TableWrapper from '../../../components/Table/TableWrapper';

/* eslint-disable react/no-array-index-key */
const ContentRepositories = ({ contentType, id, tabKey }) => {
  const status = useSelector(selectRepositoryContentDetailsStatus);
  const response = useSelector(selectRepositoryContentDetails);
  const error = useSelector(selectRepositoryContentDetailsError);
  const [searchQuery, updateSearchQuery] = useState('');
  const { results, ...metadata } = response;

  const config = contentConfig.find(type => type.names.pluralLabel === contentType);
  const typeSingularLabel = config.names.singularLabel;
  const { columnHeaders } = config.tabs.find(header => header.tabKey === tabKey);

  const emptyContentTitle = __("You currently don't have any repositories associated with this content.");
  const emptyContentBody = __('Please add some repositories.');
  const emptySearchTitle = __('No matching repositories found');
  const emptySearchBody = __('Try changing your search settings.');

  return (
    <TableWrapper
      {...{
        metadata,
        searchQuery,
        updateSearchQuery,
        error,
        status,
        emptyContentTitle,
        emptySearchTitle,
        emptySearchBody,
        emptyContentBody,
      }}
      ouiaId="content-repositories-table"
      variant={TableVariant.compact}
      autocompleteEndpoint="/katello/api/v2/repositories"
      bookmarkController="katello_repositories"
      fetchItems={useCallback(
        params => getRepositoryContentDetails(typeSingularLabel, id, params),
        [typeSingularLabel, id],
      )}
    >
      <Thead>
        <Tr ouiaId="content-repositories-column-headers-row">
          {columnHeaders.map(col =>
            <Th key={col.title}>{col.title}</Th>)}
        </Tr>
      </Thead>
      <Tbody>
        {results?.map((details, idx) => (
          <Tr key={`${details.id}`} ouiaId={`content-repositories-row-${idx}`}>
            {columnHeaders.map((col, index) =>
              <Td key={index}>{col.getProperty(details, typeSingularLabel)}</Td>)
            }
          </Tr>
        ))
        }
      </Tbody>
    </TableWrapper>
  );
};

export default ContentRepositories;

ContentRepositories.propTypes = {
  contentType: PropTypes.string.isRequired,
  id: PropTypes.number.isRequired,
  tabKey: PropTypes.string.isRequired,
};
