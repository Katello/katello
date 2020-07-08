import { translate as __ } from 'foremanReact/common/I18n';
import { headerFormatter, cellFormatter } from '../../../components/pf3Table';

export const columns = [
  {
    property: 'status',
    header: {
      label: __('Status'),
      formatters: [headerFormatter],
      props: {
        index: 0,
      },
    },
    cell: {
      formatters: [cellFormatter],
    },
  },
  {
    property: 'statusMessage',
    header: {
      label: __('Message'),
      formatters: [headerFormatter],
      props: {
        index: 1,
      },
    },
    cell: {
      formatters: [cellFormatter],
    },
  },
  // TODO: use date formatter from tomas' PR
  {
    property: 'created',
    header: {
      label: __('Timestamp'),
      formatters: [headerFormatter],
      props: {
        index: 2,
      },
    },
    cell: {
      formatters: [cellFormatter],
    },
  },
];

export default columns;
