import React from '@theforeman/vendor/react';
import {
  headerFormatter,
  cellFormatter,
} from '../../../../move_to_foreman/components/common/table';
import ProfileRpmsCellFormatter from './ProfileRpmsCellFormatter';

const TableSchema = [
  {
    property: 'name',
    header: {
      label: __('Name'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [cellFormatter],
    },
  },
  {
    property: 'rpms',
    header: {
      label: __('RPMs'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [
        (value, { rowData }) => (
          <ProfileRpmsCellFormatter rpms={rowData.rpms} />
        ),
      ],
    },
  },
];

export default TableSchema;
