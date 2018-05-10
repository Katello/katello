import React from 'react';
import { Table } from 'patternfly-react';

export default {
  urlBuilder(controller, action, id = undefined) {
    return `/${controller}/${id ? `${id}/` : ''}${action}`;
  },
};

export const KEY_CODES = {
  TAB_KEY: 9,
  ENTER_KEY: 13,
  ESCAPE_KEY: 27,
};

export const selectionHeaderCellFormatter = (selectionController, label) => (
  <Table.SelectionHeading aria-label={label}>
    <Table.Checkbox
      id="selectAll"
      label={label}
      checked={selectionController.allRowsSelected()}
      onChange={() => selectionController.selectAllRows()}
    />
  </Table.SelectionHeading>
);

export const selectionCellFormatter = (selectionController, value, additionalData) => (
  <Table.SelectionCell>
    <Table.Checkbox
      id={`select${additionalData.rowIndex}`}
      label={__('Select row')}
      checked={selectionController.isSelected(additionalData)}
      onChange={() => selectionController.selectRow(additionalData)}
    />
  </Table.SelectionCell>
);
