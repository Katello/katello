import React from 'react';
import { Icon } from 'patternfly-react';
import helpers from '../../move_to_foreman/common/helpers';
import {
  selectionHeaderCellFormatter,
  selectionCellFormatter,
  headerFormat,
  cellFormat,
} from '../../move_to_foreman/components/common/table';

export const columns = [
  {
    property: 'select',
    header: {
      label: 'Select all rows',
      props: {
        index: 0,
        rowSpan: 1,
        colSpan: 1,
      },
      customFormatters: [selectionHeaderCellFormatter],
    },
    cell: {
      props: {
        index: 0,
      },
      formatters: [
        (value, { rowData, rowIndex }) => selectionCellFormatter(
          { rowData, rowIndex },
          () => {},
        ),
      ],
    },
  },
  {
    property: 'id',
    header: {
      label: __('Name'),
      formatters: [headerFormat],
      props: {
        index: 1,
      },
    },
    cell: {
      formatters: [
        (value, { rowData }) => (
          <td>
            <a href={helpers.urlBuilder('subscriptions', '', rowData.id)}>
              {rowData.name}
            </a>
          </td>
        ),
      ],
    },
  },
  {
    property: 'product_id',
    header: {
      label: __('SKU'),
      formatters: [headerFormat],
      props: {
        index: 2,
      },
    },
    cell: {
      formatters: [cellFormat],
    },
  },
  {
    property: 'contract_number',
    header: {
      label: __('Contract'),
      formatters: [headerFormat],
      props: {
        index: 3,
      },
    },
    cell: {
      formatters: [cellFormat],
    },
  },
  // TODO: use date formatter from tomas' PR
  {
    property: 'start_date',
    header: {
      label: __('Start Date'),
      formatters: [headerFormat],
      props: {
        index: 4,
      },
    },
    cell: {
      formatters: [cellFormat],
    },
  },
  {
    property: 'end_date',
    header: {
      label: __('End Date'),
      formatters: [headerFormat],
      props: {
        index: 5,
      },
    },
    cell: {
      formatters: [cellFormat],
    },
  },
  {
    property: 'virt_who',
    header: {
      label: __('Requires Virt-Who'),
      formatters: [headerFormat],
      props: {
        index: 6,
      },
    },
    cell: {
      formatters: [
        cell => (
          <td>
            <Icon type="fa" name={cell.virt_who ? 'check' : 'minus'} />
          </td>
        ),
      ],
    },
  },
  {
    property: 'consumed',
    header: {
      label: __('Consumed'),
      formatters: [headerFormat],
      props: {
        index: 7,
      },
    },
    cell: {
      formatters: [cellFormat],
    },
  },
  {
    property: 'entitlements',
    header: {
      label: __('Entitlements'),
      formatters: [headerFormat],
      props: {
        index: 8,
      },
    },
    cell: {
      formatters: [
        (value, { rowData }) => (
          <td>
            {rowData.available === -1 ? __('Unlimited') : rowData.consumed }
          </td>
        ),
      ],
    },
  },
];

export default columns;
