/* eslint-disable import/prefer-default-export */
import React from 'react';
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

// Helper function to format dates consistently
const formatDate = (dateString) => {
  if (!dateString) return <td>—</td>;
  const date = new Date(dateString);
  if (Number.isNaN(date.getTime())) return <td>—</td>;
  return <td>{date.toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })}</td>;
};

// Helper function to format SKU
const skuFormatter = (value, { rowData }) => {
  if (!rowData.upstream_pool_id) {
    return <td>—</td>;
  }
  return cellFormatter(value, { rowData });
};

const textFormatter = (value, additionalData) => {
  if (!value) return <td>—</td>;
  return cellFormatter(value, additionalData);
};

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
          additionalData.disabled = !hasPermission || !additionalData.rowData.upstream_pool_id;

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
      formatters: [subscriptionNameFormatter],
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
      formatters: [skuFormatter],
    },
  },
  {
    property: 'contract_number',
    header: {
      label: __('Contract'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [textFormatter],
    },
  },
  {
    property: 'start_date',
    header: {
      label: __('Start date'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [(value, { rowData }) => formatDate(rowData.start_date)],
    },
  },
  {
    property: 'end_date',
    header: {
      label: __('End date'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [(value, { rowData }) => formatDate(rowData.end_date)],
    },
  },
  {
    property: 'virt_who',
    header: {
      label: __('Requires virt-who'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [
        (value, { rowData }) => {
          if (rowData.virt_who === null || rowData.virt_who === undefined) {
            return <td>—</td>;
          }
          return <td>{rowData.virt_who ? __('True') : __('False')}</td>;
        },
      ],
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
      label: __('Hosts'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [cellFormatter],
    },
  },
];
