import React from 'react';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  headerFormatter,
  cellFormatter,
} from '../../../components/pf3Table';

const TableSchema = [
  {
    property: 'name',
    header: {
      label: __('Name'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [
        (value, { rowData }) => (
          <td>
            <a href={urlBuilder(`products/${rowData.product_id}/repositories`, '', rowData.id)}>
              {rowData.name}
            </a>
          </td>
        ),
      ],
    },
  },
  {
    property: 'product_name',
    header: {
      label: __('Product'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [cellFormatter],
    },
  },
];

export default TableSchema;
