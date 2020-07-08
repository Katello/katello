import React from 'react';
import { FormGroup, FormControl, ControlLabel, HelpBlock } from 'react-bootstrap';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  headerFormatter,
  cellFormatter,
} from '../../../components/pf3Table';

export const columns = controller => [
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
            <a href={`https://access.redhat.com/management/subscriptions/${rowData.subscription_id}`} rel="noopener noreferrer" target="_blank">
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
    property: 'available',
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
            <FormGroup
              validationState={controller.quantityValidationInput(rowData)}
            >
              <ControlLabel srOnly>{__('Number to Allocate')}</ControlLabel>
              <FormControl
                type="text"
                onBlur={e => controller.onChange(e.target.value, rowData)}
                defaultValue={rowData.updatedQuantity}
                onChange={(e) => {
                  controller.onChange(e.target.value, rowData);
                }}
                onKeyDown={(e) => {
                  const key = e.charCode ? e.charCode : e.keyCode;
                  if (key === 13) {
                    controller.saveUpstreamSubscriptions();
                    e.preventDefault();
                  }
                }}
              />
              {controller.quantityValidationInput(rowData) === 'error' &&
                <HelpBlock>{controller.quantityValidation(rowData)[1]}</HelpBlock>}
            </FormGroup>
          </td>
        ),
      ],
    },
  },
];

export default columns;
