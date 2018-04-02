import React from 'react';
import { Form, FormGroup, FormControl, ControlLabel } from 'react-bootstrap';
import helpers from '../../../move_to_foreman/common/helpers';
import { headerFormat, cellFormat } from '../../../move_to_foreman/components/common/table';

export const columns = [
  {
    property: 'id',
    header: {
      label: __('Subscription Name'),
      formatters: [headerFormat],
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
    },
    cell: {
      formatters: [
        (value, { rowData }) => (
          <td>
            <Form>
              <FormGroup>
                <ControlLabel srOnly>{__('Number to Allocate')}</ControlLabel>
                <FormControl type="text" placeholder={value} /> of {rowData.quantity}
              </FormGroup>
            </Form>
          </td>
        ),
      ],
    },
  },
];

export default columns;
