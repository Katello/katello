import React from 'react';
import TableSelectionCell from '../components/TableSelectionCell';

export default (
  isGenericRow,
  selectionController,
  additionalData,
  before,
  after,
) => (

  <TableSelectionCell
    id={`select${additionalData.rowIndex}`}
    checked={selectionController.isSelected(additionalData)}
    hide={isGenericRow}
    onChange={() => selectionController.selectRow(additionalData)}
    before={before}
    after={after}
    disabled={additionalData.disabled}
  />
);
