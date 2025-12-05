import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';

export const subscriptionTypeFormatter = (value, { rowData }) => {
  let cellContent;

  if (rowData.virt_only === false) {
    cellContent = __('Physical');
  } else if (rowData.hypervisor) {
    const hypervisorLink = urlBuilder(`new/hosts/${rowData.hypervisor.id}`, '');
    cellContent = (
      <span>
        {__('Guests of')}
        {' '}
        <a href={hypervisorLink}>{rowData.hypervisor.name}</a>
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
