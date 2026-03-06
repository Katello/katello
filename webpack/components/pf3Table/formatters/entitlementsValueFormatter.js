import React from 'react';
import { Table as PfTable } from 'patternfly-react';
import { getEntitlementsDisplayValue } from '../../../scenes/Subscriptions/components/SubscriptionsTable/SubscriptionsTableHelpers.js';

export default (quantity, additionalData) => {
  const { collapsible } = additionalData.rowData;
  const value = getEntitlementsDisplayValue({
    quantity, collapsible,
  });

  return (
    <PfTable.Cell>
      {value}
    </PfTable.Cell>
  );
};
