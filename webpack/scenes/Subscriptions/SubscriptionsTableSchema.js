import React from 'react';
import { Icon } from 'patternfly-react';
import helpers, { selectionHeaderCellFormatter, selectionCellFormatter } from '../../move_to_foreman/common/helpers';
import { entitlementsInlineEditFormatter } from './EntitlementsInlineEditFormatter';
import { headerFormat, cellFormat } from '../../move_to_foreman/components/common/table';

export const columns = (inlineEditController, selectionController) => [
  {
    property: 'select',
    header: {
      label: __('Select all rows'),
      formatters: [label => selectionHeaderCellFormatter(selectionController, label)],
    },
    cell: {
      formatters: [(value, additionalData) =>
        selectionCellFormatter(selectionController, value, additionalData)],
    },
  },
  {
    property: 'id',
    header: {
      label: __('Name'),
      formatters: [headerFormat],
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
    },
    cell: {
      formatters: [cellFormat],
    },
  }, // TODO: use date formatter from tomas' PR
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
    property: 'virt_who',
    header: {
      label: __('Requires Virt-Who'),
      formatters: [headerFormat],
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
    },
    cell: {
      formatters: [cellFormat],
    },
  },
  {
    property: 'quantity',
    header: {
      label: __('Entitlements'),
      formatters: [headerFormat],
    },
    cell: {
      formatters: [
        entitlementsInlineEditFormatter(inlineEditController),
      ],
    },
  },
];

export default columns;
