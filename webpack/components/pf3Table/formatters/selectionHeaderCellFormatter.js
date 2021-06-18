import React from 'react';
import TableSelectionHeaderCell from '../components/TableSelectionHeaderCell';

export default (selectionController, label, selectionEnabled) => (
  <TableSelectionHeaderCell
    label={label}
    checked={selectionController.allRowsSelected()}
    onChange={() => selectionController.selectAllRows()}
    disabled={!selectionEnabled}
  />
);
