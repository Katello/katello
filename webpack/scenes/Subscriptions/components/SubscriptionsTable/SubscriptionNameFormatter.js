import React from 'react';
import { Link } from 'react-router-dom';
import { urlBuilder } from 'foremanReact/common/urlHelpers';

export const subscriptionNameFormatter = (value, { rowData }) => {
  let cellContent;

  if (rowData.collapsible) {
    cellContent = (rowData.name);
  } else {
    cellContent = (
      <Link to={urlBuilder('subscriptions', '', rowData.id)}>{rowData.name}</Link>
    );
  }

  return (
    <td>
      {cellContent}
    </td>
  );
};

export default subscriptionNameFormatter;
