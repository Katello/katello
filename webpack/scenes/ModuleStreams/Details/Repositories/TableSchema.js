import React from 'react';
import { Link } from 'react-router-dom';
import {
  headerFormatter,
  cellFormatter,
} from '../../../../move_to_foreman/components/common/table';
import helpers from '../../../../move_to_foreman/common/helpers';

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
            <Link to={helpers.urlBuilder(`products/${rowData.product_id}/repositories`, '', rowData.id)}>{rowData.name}</Link>
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
