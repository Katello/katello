import React, { useState, useCallback, useContext } from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import TableWrapper from '../../../../../components/Table/TableWrapper';
import { getActivationKeys } from '../../ContentViewDetailActions';
import {
  selectCVActivationKeys, selectCVActivationKeysStatus,
} from '../../ContentViewDetailSelectors';
import EnvironmentLabels from '../../../components/EnvironmentLabels';
import DeleteContext from './DeleteContext';

const AffectedActivationKeys = () => {
  const { versionEnvironments, selected, cvId } = useContext(DeleteContext);
  const [searchQuery, updateSearchQuery] = useState('');
  const response = useSelector(state => selectCVActivationKeys(state), shallowEqual);
  const status = useSelector(state => selectCVActivationKeysStatus(state), shallowEqual);
  const selectedEnv = versionEnvironments.filter((_env, index) => selected[index]);

  const fetchItems = useCallback(() => {
    const formSearch = () => {
      let cvQuery = `content_view_id = ${cvId}`;
      const selectedEnvStrings = selectedEnv.map(env => `environment=${env.name}`).join(' OR ');
      if (selectedEnvStrings.length) {
        cvQuery += ' AND (';
        cvQuery += `${selectedEnvStrings} )`;
      }
      if (searchQuery.length) {
        cvQuery += ' AND (';
        cvQuery += `${searchQuery} )`;
      }
      return cvQuery;
    };
    return getActivationKeys({ search: formSearch() });
  }, [cvId, searchQuery, selectedEnv]);

  const columnHeaders = [
    __('Name'),
    __('Environment'),
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
      autocompleteEndpoint="/activation_keys/auto_complete_search"
      variant={TableVariant.compact}
    >
      <Thead>
        <Tr>
          {columnHeaders.map(col =>
            <Th key={col}>{col}</Th>)}
        </Tr>
      </Thead>
      <Tbody>
        {results?.map((result) => {
        const {
          name, id, environment,
        } = result;
        return (
          <Tr key={`${id}`}>
            <Td>
              <a rel="noreferrer" target="_blank" href={urlBuilder(`activation_keys/${id}`, '')}>{name}</a>
            </Td>
            <Td><EnvironmentLabels environments={environment} /></Td>
          </Tr>
        );
      })
      }
      </Tbody>
    </TableWrapper>
  );
};
export default AffectedActivationKeys;
