import React, { useState, useCallback } from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import TableWrapper from '../../../../../components/Table/TableWrapper';
import { selectCVHosts, selectCVHostsStatus } from '../../ContentViewDetailSelectors';
import EnvironmentLabels from '../../../components/EnvironmentLabels';
import { getHosts } from '../../ContentViewDetailActions';

const AffectedHosts = ({
  versionEnvironments, selectedEnvSet, cvId, deleteCV,
}) => {
  const [searchQuery, updateSearchQuery] = useState('');
  const response = useSelector(state => selectCVHosts(state), shallowEqual);
  const status = useSelector(state => selectCVHostsStatus(state), shallowEqual);
  const selectedEnv = deleteCV ?
    versionEnvironments :
    versionEnvironments.filter(env => selectedEnvSet?.has(env.id));


  const fetchItems = useCallback(() => {
    let cvQuery = `content_view_id=${cvId}`;
    const selectedEnvStrings = selectedEnv.map(env => `lifecycle_environment_id=${env.id}`).join(' OR ');
    if (selectedEnvStrings.length) cvQuery += ` AND (${selectedEnvStrings})`;
    if (searchQuery.length) cvQuery += ` AND (${searchQuery} )`;
    return getHosts({ search: cvQuery });
  }, [cvId, searchQuery, selectedEnv]);
  const columnHeaders = [
    __('Name'),
    __('Environment'),
  ];
  const emptyContentTitle = __('No matching hosts found.');
  const emptyContentBody = __("Given criteria doesn't match any hosts. Try changing your rule.");
  const emptySearchTitle = __('Your search returned no matching hosts.');
  const emptySearchBody = __('Try changing your search criteria.');
  const { results, ...metadata } = response;
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
        fetchItems,
        status,
      }}
      ouiaId="content-view-delete-modal-affected-hosts-table"
      autocompleteEndpoint="/api/v2/hosts"
      variant={TableVariant.compact}
    >
      <Thead>
        <Tr ouiaId="affected-hosts-table-headers">
          {columnHeaders.map(col =>
            <Th key={col}>{col}</Th>)}
        </Tr>
      </Thead>
      <Tbody>
        {results?.map(({
          name,
          id,
          content_facet_attributes: { lifecycle_environment: environment },
        }) => (
          <Tr ouiaId={id} key={id}>
            <Td>
              <a rel="noreferrer" target="_blank" href={urlBuilder(`new/hosts/${id}`, '')}>{name}</a>
            </Td>
            <Td><EnvironmentLabels environments={environment} /></Td>
          </Tr>
        ))
        }
      </Tbody>
    </TableWrapper>
  );
};

AffectedHosts.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  selectedEnvSet: PropTypes.oneOfType([
    PropTypes.func,
    PropTypes.shape({}),
  ]),
  versionEnvironments: PropTypes.arrayOf(PropTypes.shape({})),
  deleteCV: PropTypes.bool,
};

AffectedHosts.defaultProps = {
  selectedEnvSet: null,
  versionEnvironments: null,
  deleteCV: false,
};

export default AffectedHosts;
