import React from 'react';
import { FormGroup, FormControl, ControlLabel } from 'react-bootstrap';
import helpers from '../../../move_to_foreman/common/helpers';
import {
  headerFormatter,
  cellFormatter,
  selectionHeaderCellFormatter,
  selectionCellFormatter,
} from '../../../move_to_foreman/components/common/table';

export const columns = (controller, selectionController) => [
  {
    property: 'select',
    header: {
      label: __('Select all rows'),
      formatters: [label => selectionHeaderCellFormatter(selectionController, label)],
    },
    cell: {
      formatters: [
        (value, additionalData) => selectionCellFormatter(selectionController, additionalData),
      ],
    },
  },
  {
    property: 'id',
    header: {
      label: __('Subscription Name'),
      formatters: [headerFormatter],
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
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [cellFormatter],
    },
  },
  // TODO: use date formatter from tomas' PR
  {
    property: 'start_date',
    header: {
      label: __('Start Date'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [cellFormatter],
    },
  },
  {
    property: 'end_date',
    header: {
      label: __('End Date'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [cellFormatter],
    },
  },
  {
    property: 'quantity',
    header: {
      label: __('Available Entitlements'),
      formatters: [headerFormatter],
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
      formatters: [headerFormatter],
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
