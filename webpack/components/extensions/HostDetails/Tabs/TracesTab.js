import React, { useState, useCallback } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import TableWrapper from '../../../../components/Table/TableWrapper';
import { TableVariant } from '@patternfly/react-table';
import { TableComposable, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import PropTypes from 'prop-types';

const getHostTraces = () => get({
  type: API_OPERATIONS.GET,
  key: HOST_TRACES_KEY,
  url: api.getApiUrl(`/hosts/${hostId()}/traces`),
});

const TracesTab = () => {
  const [searchQuery, updateSearchQuery] = useState('');
  const composable = true;
  const emptyContentTitle = __("You currently don't have any filters for this content view.");
  const emptyContentBody = __("Add filters using the 'Add filter' button above."); // needs link
  const emptySearchTitle = __('No matching filters found');
  const emptySearchBody = __('Try changing your search settings.');
  return (
    <TableWrapper
    composable
    composableChildren = {
      <>
    <Thead>
      <Tr>
        <Th>{__('Content view')}</Th>
        <Th>{__('Version')}</Th>
        <Th>{__('Environments')}</Th>
      </Tr>
    </Thead>
    <Tbody>
      <Tr>
        <Td>
        </Td>
        <Td>
          {__('Version')} {emptyContentTitle}
        </Td>
        <Td>
        </Td>
      </Tr>
    </Tbody>
    </>
    }
    aria-label="Review Table">  
    </TableWrapper>
  );
};

TracesTab.propTypes = {
  hostId: PropTypes.number,
  composable: PropTypes.bool,
};

export default TracesTab;