import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import TableWrapper from '../../../../components/Table/TableWrapper';

const getHostTraces = () => get({
  type: API_OPERATIONS.GET,
  key: HOST_TRACES_KEY,
  url: api.getApiUrl(`/hosts/${hostId()}/traces`),
});

const TracesTab = () => {
  const [searchQuery, updateSearchQuery] = useState('');
  const emptyContentTitle = __('No Traces to show');
  const emptyContentBody = __('Click Install Tracer to start monitoring which services need restarting on this host.'); // needs link
  const emptySearchTitle = __('No matching traces found');
  const emptySearchBody = __('Try changing your search settings.');
  return (
    <TableWrapper
      composable
      searchQuery={searchQuery}
      updateSearchQuery={updateSearchQuery}
      emptyContentTitle={emptyContentTitle}
      emptyContentBody={emptyContentBody}
      emptySearchTitle={emptySearchTitle}
      emptySearchBody={emptySearchBody}
      aria-label="Review Table"
    >
      <Thead>
        <Tr>
          <Th>{__('Content view')}</Th>
          <Th>{__('Version')}</Th>
          <Th>{__('Environments')}</Th>
        </Tr>
      </Thead>
      <Tbody>
        <Tr>
          <Td />
          <Td>
            {__('Version')} {emptyContentTitle}
          </Td>
          <Td />
        </Tr>
      </Tbody>
    </TableWrapper>
  );
};

TracesTab.propTypes = {
  hostId: PropTypes.number,
  composable: PropTypes.bool,
};

export default TracesTab;
