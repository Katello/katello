import React from '@theforeman/vendor/react';
import { Link } from '@theforeman/vendor/react-router-dom';
import {
  headerFormatter,
  cellFormatter,
} from '../../move_to_foreman/components/common/table';
import helpers from '../../move_to_foreman/common/helpers';


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
            <Link to={helpers.urlBuilder('module_streams', '', rowData.id)}>{rowData.name}</Link>
          </td>
        ),
      ],
    },
  },
  {
    property: 'stream',
    header: {
      label: __('Stream'),
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
    property: 'context',
    header: {
      label: __('Context'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [cellFormatter],
    },
  },
  {
    property: 'arch',
    header: {
      label: __('Arch'),
      formatters: [headerFormatter],
    },
    cell: {
      formatters: [cellFormatter],
    },
  },
];

export default TableSchema;
