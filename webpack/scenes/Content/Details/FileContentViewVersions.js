import React, { useCallback, useState } from 'react';
import { useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import LongDateTime from 'foremanReact/components/common/dates/LongDateTime';
import TableWrapper from '../../../components/Table/TableWrapper';
import './ContentDetails.scss';
import { getFileContentViewVersions } from '../ContentActions';
import {
  selectFileContentViewVersions,
  selectFileContentViewVersionsStatus,
  selectFileContentViewVersionsError,
} from '../ContentSelectors';

const FileContentViewVersions = ({ id }) => {
  const response = useSelector(selectFileContentViewVersions);
  const status = useSelector(selectFileContentViewVersionsStatus);
  const error = useSelector(selectFileContentViewVersionsError);
  const [searchQuery, updateSearchQuery] = useState('');
  const { results = [], ...metadata } = response;

  const fetchItems = useCallback(
    params => getFileContentViewVersions(id, params),
    [id],
  );

  return (
    <TableWrapper
      metadata={metadata}
      status={status}
      error={error}
      searchQuery={searchQuery}
      updateSearchQuery={updateSearchQuery}
      fetchItems={fetchItems}
      autocompleteEndpoint="/katello/api/v2/content_view_versions"
      autocompleteQueryParams={{ file_id: id, nondefault: true }}
      ouiaId="file-content-view-versions-table"
      variant={TableVariant.compact}
      className="katello-pf4-table katello-content-details-table-inset"
      isStriped
      emptyContentTitle={__('No content views contain this file')}
      emptyContentBody={__('Content view versions containing this file will appear here.')}
      emptySearchTitle={__('No matching content view versions found')}
      emptySearchBody={__('Try changing your search settings.')}
    >
      <Thead>
        <Tr ouiaId="file-content-view-versions-headers">
          <Th>{__('Name')}</Th>
          <Th>{__('Version')}</Th>
          <Th>{__('Environment')}</Th>
          <Th>{__('Published')}</Th>
        </Tr>
      </Thead>
      <Tbody>
        {results.map(version => (
          <Tr
            key={version.id}
            ouiaId={`file-content-view-version-${version.id}`}
          >
            <Td dataLabel={__('Name')}>
              <a href={urlBuilder(`content_views/${version.content_view.id}`, '')}>
                {version.content_view.name}
              </a>
            </Td>
            <Td dataLabel={__('Version')}>{version.version}</Td>
            <Td dataLabel={__('Environment')}>
              {version.environments?.map(environment => environment.name).join(', ')}
            </Td>
            <Td dataLabel={__('Published')}>
              {version.created_at ? (
                <LongDateTime date={version.created_at} showRelativeTimeTooltip />
              ) : '—'}
            </Td>
          </Tr>
        ))}
      </Tbody>
    </TableWrapper>
  );
};

FileContentViewVersions.propTypes = {
  id: PropTypes.number.isRequired,
};

export default FileContentViewVersions;
