import { headerFormat, cellFormat } from '../../../move_to_foreman/components/common/table';

export const columns = [
  {
    property: 'status',
    header: {
      label: __('Status'),
      formatters: [headerFormat],
      props: {
        index: 0,
      },
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
      props: {
        index: 1,
      },
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
      props: {
        index: 2,
      },
    },
    cell: {
      formatters: [cellFormat],
    },
  },
];

export default columns;
