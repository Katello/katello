import React from 'react';
import { FormGroup, FormControl, ControlLabel } from 'react-bootstrap';
import helpers from '../../../move_to_foreman/common/helpers';
import {
  headerFormat,
  cellFormat,
  selectionHeaderCellFormatter,
  selectionCellFormatter,
} from '../../../move_to_foreman/components/common/table';

export const columns = controller => [
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
          controller.onSelectRow,
        ),
      ],
    },
  },
  {
    property: 'id',
    header: {
      label: __('Subscription Name'),
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
              {rowData.product_name}
            </a>
          </td>
        ),
      ],
    },
  },
  {
    property: 'contract_number',
    header: {
      label: __('Contract'),
      formatters: [headerFormat],
      props: {
        index: 2,
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
        index: 3,
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
        index: 4,
      },
    },
    cell: {
      formatters: [cellFormat],
    },
  },
  {
    property: 'quantity',
    header: {
      label: __('Available Entitlements'),
      formatters: [headerFormat],
      props: {
        index: 5,
      },
    },
    cell: {
      formatters: [
        value => (
          <td>
            {value === -1 ? __('Unlimited') : value }
          </td>
        ),
      ],
    },
  },
  {
    property: 'consumed',
    header: {
      label: __('Quantity to Allocate'),
      formatters: [headerFormat],
      props: {
        index: 6,
      },
    },
    cell: {
      formatters: [
        (value, { rowData }) => (
          <td>
            <FormGroup>
              <ControlLabel srOnly>{__('Number to Allocate')}</ControlLabel>
              <FormControl
                type="text"
                onBlur={e => controller.onChange(e.target.value, rowData)}
                defaultValue={rowData.updatedQuantity}
                onKeyDown={(e) => {
                  const key = e.charCode ? e.charCode : e.keyCode;
                  if (key === 13) {
                    controller.onChange(e.target.value, rowData);
                    controller.saveUpstreamSubscriptions();
                    e.preventDefault();
                  }
                }}
              />
              <div>{__('Max')} {rowData.quantity}</div>
            </FormGroup>
          </td>
        ),
      ],
    },
  },
];

export default columns;
