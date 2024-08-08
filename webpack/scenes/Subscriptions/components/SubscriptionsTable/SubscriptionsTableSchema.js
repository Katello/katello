/* eslint-disable import/prefer-default-export */
import React from 'react';
import { Icon } from 'patternfly-react';
import { translate as __ } from 'foremanReact/common/I18n';
import entitlementsValueFormatter from '../../../../components/pf3Table/formatters/entitlementsValueFormatter.js';
import { entitlementsInlineEditFormatter } from '../../../../components/pf3Table/formatters/EntitlementsInlineEditFormatter';
import { subscriptionTypeFormatter } from './SubscriptionTypeFormatter';
import { subscriptionNameFormatter } from './SubscriptionNameFormatter';
import {
  headerFormatter,
  cellFormatter,
  selectionHeaderCellFormatter,
  collapseableAndSelectionCellFormatter,
} from '../../../../components/pf3Table';

function getEntitlementsFormatter(inlineEditController, canManageSubscriptionAllocations) {
  if (canManageSubscriptionAllocations) {
    return entitlementsInlineEditFormatter(inlineEditController);
  }
  return entitlementsValueFormatter;
}

export const createSubscriptionsTableSchema = (
  inlineEditController,
  selectionController,
  groupingController,
  hasPermission,
) => [
  {
    property: 'select',
    header: {
      label: __('Select all rows'),
      formatters: [
        label => selectionHeaderCellFormatter(selectionController, label, hasPermission),
      ],
    },
    cell: {
      formatters: [
        (value, additionalData) => {
          // eslint-disable-next-line no-param-reassign
          additionalData.disabled = !hasPermission || additionalData.rowData.available === -1;

          return collapseableAndSelectionCellFormatter(
            groupingController,
            selectionController,
            additionalData,
          );
        },
      ],
    },
  },
  {
    property: 'id',
    header: {
      label: __('Name'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [subscriptionNameFormatter]
      ,
    },
  },
  {
    property: 'type',
    header: {
      label: __('Type'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [subscriptionTypeFormatter],
    },
  },
  {
    property: 'product_id',
    header: {
      label: __('SKU'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [cellFormatter],
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
  }, // TODO: use date formatter from tomas' PR
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
    property: 'virt_who',
    header: {
      label: __('Requires Virt-Who'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [
        (value, { rowData }) => (
          <td>
            <Icon type="fa" name={rowData.virt_who ? 'check' : 'minus'} />
          </td>
        ),
      ],
    },
  },
  {
    property: 'consumed',
    header: {
      label: __('Consumed'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [cellFormatter],
    },
  },
  {
    property: 'quantity',
    header: {
      label: __('Entitlements'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [getEntitlementsFormatter(inlineEditController, hasPermission)],
    },
  },
  {
    property: 'product_host_count',
    header: {
      label: __('Product Host Count'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [cellFormatter],
    },
  },
];
