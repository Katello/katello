import { headerFormat, cellFormat } from '../../../move_to_foreman/components/common/table';

export const columns = [
  {
    property: 'status',
    header: {
      label: __('Status'),
      formatters: [headerFormat],
    },
    cell: {
      formatters: [cellFormat],
    },
  },
  {
    property: 'statusMessage',
    header: {
      label: __('Message'),
      formatters: [headerFormat],
    },
    cell: {
      formatters: [cellFormat],
    },
  },
  // TODO: use date formatter from tomas' PR
  {
    property: 'created',
    header: {
      label: __('Timestamp'),
      formatters: [headerFormat],
    },
    cell: {
      formatters: [cellFormat],
    },
  },
];

export default columns;
