import React from 'react';
import { Link } from 'react-router-dom';
import { urlBuilder } from 'foremanReact/common/urlHelpers';

export const subscriptionTypeFormatter = (value, { rowData }) => {
  let cellContent;

  if (rowData.virt_only === false) {
    cellContent = __('Physical');
  } else if (rowData.hypervisor) {
    cellContent = (
      <span>
        {__('Guests of')}
        {' '}
        <Link to={urlBuilder('content_hosts', '', rowData.hypervisor.id)}>{rowData.hypervisor.name}</Link>
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
