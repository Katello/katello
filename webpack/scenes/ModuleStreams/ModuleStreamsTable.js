import React from 'react';
import PropTypes from 'prop-types';
import { Table } from '../../move_to_foreman/components/common/table';
import TableSchema from './ModuleStreamsTableSchema';
import { LoadingState } from '../../move_to_pf/LoadingState';

const ModuleStreamsTable = ({ moduleStreams, onPaginationChange }) => {
  const {
    loading, results, pagination, itemCount,
  } = moduleStreams;

  const emptyStateData = {
    header: __('No Module Streams found'),
  };

  return (
    <LoadingState
      loading={!results || loading}
      loadingText={__('Loading')}
    >
      <Table
        columns={TableSchema}
        rows={results}
        pagination={pagination}
        onPaginationChange={onPaginationChange}
        itemCount={itemCount}
        emptyState={emptyStateData}
      />
    </LoadingState>
  );
};

ModuleStreamsTable.propTypes = {
  moduleStreams: PropTypes.shape({
    loading: PropTypes.bool,
    results: PropTypes.array,
    pagination: PropTypes.shape({}),
    itemCount: PropTypes.number,
  }).isRequired,
  onPaginationChange: PropTypes.func.isRequired,
};

export default ModuleStreamsTable;
