// Meant for when the user has none of the object created, not when a search returns empty results
import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import EmptyStateMessage from './EmptyStateMessage';

const title = __("You currently don't have any Content Views.");
const body = __('A Content View can be added by using the "New content view" button above.');

const emptyRows = [{
  heightAuto: true,
  noactions: 'true',
  cells: [
    {
      props: { colSpan: 6, noactions: 'true' },
      title: <EmptyStateMessage {...{ title, body }} />,
    },
  ],
}];

export default emptyRows;
