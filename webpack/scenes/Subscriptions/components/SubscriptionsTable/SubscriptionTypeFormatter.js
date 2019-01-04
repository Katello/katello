import React from '@theforeman/vendor/react';
import { Link } from '@theforeman/vendor/react-router-dom';
import helpers from '../../../../move_to_foreman/common/helpers';

export const subscriptionTypeFormatter = (value, { rowData }) => {
  let cellContent;

  if (rowData.virt_only === false) {
    cellContent = __('Physical');
  } else if (rowData.hypervisor) {
    cellContent = (
      <span>
        {__('Guests of')}
        {' '}
        <Link to={helpers.urlBuilder('content_hosts', '', rowData.hypervisor.id)}>{rowData.hypervisor.name}</Link>
      </span>
    );
  } else if (rowData.unmapped_guest) {
    cellContent = __('Temporary');
  } else {
    cellContent = __('Virtual');
  }

  return (
    <td>
      {cellContent}
    </td>
  );
};

export default subscriptionTypeFormatter;
