import React from 'react';
import PropTypes from 'prop-types';
import { Table, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { getDocsURL } from 'foremanReact/common/helpers';
import EmptyState from 'foremanReact/components/common/EmptyState';
import { translate as __ } from 'foremanReact/common/I18n';

const ManifestHistoryContent = ({ manifestHistory }) => {
  if (manifestHistory.results.length === 0) {
    return (
      <EmptyState
        header={__('There is no manifest history to display.')}
        description={__('Import a manifest using the Manifest tab above.')}
        documentation={{
          label: __('Learn more about adding subscription manifests in '),
          buttonLabel: __('the documentation.'),
          url: getDocsURL('Managing_Content', 'Managing_Red_Hat_Subscriptions_content-management'),
        }}
      />
    );
  }

  return (
    <Table
      ouiaId="manifest-history-table"
      aria-label={__('Manifest history table')}
    >
      <Thead>
        <Tr ouiaId="manifest-history-header-row">
          <Th>{__('Status')}</Th>
          <Th>{__('Message')}</Th>
          <Th>{__('Timestamp')}</Th>
        </Tr>
      </Thead>
      <Tbody>
        {manifestHistory.results.map((record, index) => (
          <Tr
            key={`${record.created}-${record.statusMessage}`}
            ouiaId={`manifest-history-row-${index}`}
          >
            <Td>{record.status}</Td>
            <Td>{record.statusMessage}</Td>
            <Td>{record.created}</Td>
          </Tr>
        ))}
      </Tbody>
    </Table>
  );
};

ManifestHistoryContent.propTypes = {
  manifestHistory: PropTypes.shape({
    results: PropTypes.arrayOf(PropTypes.shape({
      status: PropTypes.string,
      statusMessage: PropTypes.string,
      created: PropTypes.string,
    })),
  }).isRequired,
};

export default ManifestHistoryContent;
