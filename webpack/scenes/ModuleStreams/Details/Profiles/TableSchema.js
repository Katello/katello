import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  headerFormatter,
  cellFormatter,
} from '../../../../components/pf3Table';
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
