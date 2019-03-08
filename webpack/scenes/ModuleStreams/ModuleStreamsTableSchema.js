import React from 'react';
import { Link } from 'react-router-dom';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import {
  headerFormatter,
  cellFormatter,
} from '../../move_to_foreman/components/common/table';


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
            <Link to={urlBuilder('module_streams', '', rowData.id)}>{rowData.name}</Link>
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
