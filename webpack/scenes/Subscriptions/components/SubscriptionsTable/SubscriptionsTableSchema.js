/* eslint-disable import/prefer-default-export */
import React from 'react';
import { Icon } from 'patternfly-react';
import { Link } from 'react-router-dom';
import helpers from '../../../../move_to_foreman/common/helpers';
import { entitlementsInlineEditFormatter } from './EntitlementsInlineEditFormatter';
import {
  headerFormatter,
  cellFormatter,
  selectionHeaderCellFormatter,
  collapseableAndSelectionCellFormatter,
} from '../../../../move_to_foreman/components/common/table';

export const createSubscriptionsTableSchema = (
  inlineEditController,
  selectionController,
  groupingController,
) => [
  {
    property: 'select',
    header: {
      label: __('Select all rows'),
      formatters: [label => selectionHeaderCellFormatter(selectionController, label)],
    },
    cell: {
      formatters: [
        (value, additionalData) =>
          collapseableAndSelectionCellFormatter(
            groupingController,
            selectionController,
            additionalData,
          ),
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
      formatters: [
        (value, { rowData }) => (
          <td>
            <Link to={helpers.urlBuilder('xui/subscriptions', '', rowData.id)}>{rowData.name}</Link>
          </td>
        ),
      ],
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
      formatters: [entitlementsInlineEditFormatter(inlineEditController)],
    },
  },
];
