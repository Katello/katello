import React from 'react';
import PropTypes from 'prop-types';
import { Table } from '../../move_to_foreman/components/common/table';
import TableSchema from './AnsibleCollectionsTableSchema';
import { LoadingState } from '../../move_to_pf/LoadingState';

const AnsibleCollectionsTable = ({ ansibleCollections, onPaginationChange }) => {
  const {
    loading, results, pagination, itemCount,
  } = ansibleCollections;

  const emptyStateData = {
    header: __('No Ansible Collections found'),
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

AnsibleCollectionsTable.propTypes = {
  ansibleCollections: PropTypes.shape({
    loading: PropTypes.bool,
    results: PropTypes.array,
    pagination: PropTypes.shape({}),
    itemCount: PropTypes.number,
  }).isRequired,
  onPaginationChange: PropTypes.func.isRequired,
};


export default AnsibleCollectionsTable;
