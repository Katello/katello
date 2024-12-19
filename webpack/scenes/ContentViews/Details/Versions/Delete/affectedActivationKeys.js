import React, { useState, useCallback } from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import TableWrapper from '../../../../../components/Table/TableWrapper';
import { getActivationKeys } from '../../ContentViewDetailActions';
import {
  selectCVActivationKeys, selectCVActivationKeysStatus,
} from '../../ContentViewDetailSelectors';
import EnvironmentLabels from '../../../components/EnvironmentLabels';

const AffectedActivationKeys = ({
  versionEnvironments, selectedEnvSet, cvId, deleteCV,
}) => {
  const [searchQuery, updateSearchQuery] = useState('');
  const response = useSelector(state => selectCVActivationKeys(state), shallowEqual);
  const status = useSelector(state => selectCVActivationKeysStatus(state), shallowEqual);
  const selectedEnv = deleteCV ?
    versionEnvironments :
    versionEnvironments.filter(env => selectedEnvSet?.has(env.id));

  const fetchItems = useCallback(() => {
    const formSearch = () => {
      let cvQuery = `content_view_id = ${cvId}`;
      const selectedEnvStrings = selectedEnv.map(env => `environment=${env.name}`).join(' OR ');
      if (selectedEnvStrings.length) cvQuery += ` AND ( ${selectedEnvStrings} )`;
      if (searchQuery.length) cvQuery += ` AND ( ${searchQuery} )`;
      return cvQuery;
    };
    return getActivationKeys({ search: formSearch() });
  }, [cvId, searchQuery, selectedEnv]);

  const columnHeaders = [
    __('Name'),
    __('Environment'),
    __('Multi Content View Environment'),
  ];
  const emptyContentTitle = __('No matching activation keys found.');
  const emptyContentBody = __("Given criteria doesn't match any activation keys. Try changing your rule.");
  const emptySearchTitle = __('Your search returned no matching activation keys.');
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
      ouiaId="content-view-delete-modal-affected-activation-keys"
      autocompleteEndpoint="/katello/api/v2/activation_keys"
      variant={TableVariant.compact}
    >
      <Thead>
        <Tr ouiaId="affected-activation-keys-header">
          {columnHeaders.map(col =>
            <Th key={col}>{col}</Th>)}
        </Tr>
      </Thead>
      <Tbody>
        {results?.map(({
          name, id, environment, multi_content_view_environment: multiContentViewEnvironment,
        }) => (
          <Tr ouiaId={id} key={id}>
            <Td>
              <a rel="noreferrer" target="_blank" href={urlBuilder(`activation_keys/${id}`, '')}>{name}</a>
            </Td>
            <Td><EnvironmentLabels environments={environment} /></Td>
            <Td>{ multiContentViewEnvironment ? 'Yes' : 'No' }</Td>
          </Tr>
        ))
        }
      </Tbody>
    </TableWrapper>
  );
};

AffectedActivationKeys.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  selectedEnvSet: PropTypes.oneOfType([
    PropTypes.func,
    PropTypes.shape({}),
  ]),
  versionEnvironments: PropTypes.arrayOf(PropTypes.shape({})),
  deleteCV: PropTypes.bool,
};

AffectedActivationKeys.defaultProps = {
  selectedEnvSet: null,
  versionEnvironments: null,
  deleteCV: false,
};
export default AffectedActivationKeys;
