import React from '@theforeman/vendor/react';
import TableSelectionHeaderCell from '../components/TableSelectionHeaderCell';

export default (selectionController, label) => (
  <TableSelectionHeaderCell
    label={label}
    checked={selectionController.allRowsSelected()}
    onChange={() => selectionController.selectAllRows()}
  />
);
