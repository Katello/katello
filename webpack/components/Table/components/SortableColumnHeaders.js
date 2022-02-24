import React from 'react';
import { Th } from '@patternfly/react-table';

const SortableColumnHeaders = ({
  columnHeaders,
  pfSortParams,
  columnsToSortParams,
}) => (
  columnHeaders.map(col => (
    <Th
      key={col}
      sort={columnsToSortParams[col] ? pfSortParams(col) : undefined}
    >
      {col}
    </Th>
  ))
);

export default SortableColumnHeaders;
