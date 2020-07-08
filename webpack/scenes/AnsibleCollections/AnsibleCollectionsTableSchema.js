import React from 'react';
import { Link } from 'react-router-dom';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import {
  headerFormatter,
  cellFormatter,
} from '../../components/pf3Table/formatters';

const TableSchema = [
  {
    property: 'name',
    header: {
      label: __('Name'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [
        (value, { rowData }) => (
          <td>
            <Link to={urlBuilder('ansible_collections', '', rowData.id)}>{rowData.name}</Link>
          </td>
        ),
      ],
    },
  },
  {
    property: 'namespace',
    header: {
      label: __('Author'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [cellFormatter],
    },
  },
  {
    property: 'version',
    header: {
      label: __('Version'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [cellFormatter],
    },
  },
  {
    property: 'checksum',
    header: {
      label: __('Checksum'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [cellFormatter],
    },
  },
];

export default TableSchema;

