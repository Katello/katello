import React, {useState, useCallback } from 'react';
import { Skeleton, Button, FlexItem, Flex } from '@patternfly/react-core'
import { translate as __ } from 'foremanReact/common/I18n';
import TableWrapper from '../../../../components/Table/TableWrapper';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import PropTypes from 'prop-types';
import { useSelector } from 'react-redux';
import getHostTraces from './HostTracesActions'
import { selectHostTracesStatus, selectHostTraces, selectHostTracesError, selectHostId } from './HostTracesSelectors'
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
const TracesTab = () => {
  const [searchQuery, updateSearchQuery] = useState('');
  const response = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'))
  const hostId = response.id
  const emptyContentTitle = __("NO TRACES");
  const emptyContentBody = __("Add filters using the 'Add filter' button above."); // needs link
  const emptySearchTitle = __('No matching filters found');
  const emptySearchBody = __('Try changing your search settings.');
  const actionButtons = <Button variant="danger" isDisabled> Restart app </Button>
  const fetchItems = useCallback(() => {
    if (!hostId) return;
    return getHostTraces(hostId);
  }, [hostId])
  const hostTraces = useSelector(state => selectAPIResponse(state, 'HOST_TRACES')).results
  const status = useSelector(state => selectHostTracesStatus(state));
  console.log(hostTraces);
  if (!hostId) return <Skeleton />;
  return (
    <TableWrapper
    composable
    actionButtons={actionButtons}
    searchQuery={searchQuery}
    emptyContentBody={emptyContentBody}
    emptyContentTitle={emptyContentTitle}
    emptySearchBody={emptySearchBody}
    emptySearchTitle={emptySearchTitle}
    updateSearchQuery={updateSearchQuery}
    fetchItems={fetchItems}
    autocompleteEndpoint={`/hosts/${hostId}/traces/auto_complete_search`}
    foremanApiAutoComplete
    rowsCount={hostTraces?.results?.length}
    variant={TableVariant.compact}
    status={status}
    >
      <Thead>
        <Tr>
          <Th>{__('Application')}</Th>
          <Th>{__('Type')}</Th>
          <Th>{__('Helper')}</Th>
        </Tr>
      </Thead>
      <Tbody>
        {hostTraces?.map((result) => {
          const {
         id,
         application,
         helper,
         app_type, 
        } = result
        return (
          <Tr key={id} >
            <Td>{application}</Td>
            <Td>{helper}</Td>
            <Td>{app_type}</Td>
          </Tr>
        )
      })
    }
    </Tbody>
    </TableWrapper>
  );
};

TracesTab.propTypes = {
  hostId: PropTypes.number,
};

export default TracesTab;