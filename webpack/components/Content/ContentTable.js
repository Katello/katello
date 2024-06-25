import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import { Table } from '../../components/pf3Table';
import { LoadingState } from '../../components/LoadingState';

const ContentTable = ({ content, tableSchema, onPaginationChange }) => {
  const {
    loading, results, pagination, itemCount,
  } = content;

  const emptyStateData = {
    header: __('No Content found'),
  };

  return (
    <LoadingState
      loading={!results || loading}
      loadingText={__('Loading')}
    >
      <Table
        columns={tableSchema}
        rows={results}
        pagination={pagination}
        onPaginationChange={onPaginationChange}
        itemCount={itemCount}
        emptyState={emptyStateData}
      />
    </LoadingState>
  );
};

ContentTable.propTypes = {
  content: PropTypes.shape({
    loading: PropTypes.bool,
    // Disabling rule as existing code failed due to an eslint-plugin-react update
    // eslint-disable-next-line react/forbid-prop-types
    results: PropTypes.array,
    pagination: PropTypes.shape({}),
    itemCount: PropTypes.number,
  }).isRequired,
  onPaginationChange: PropTypes.func.isRequired,
  tableSchema: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
};


export default ContentTable;
