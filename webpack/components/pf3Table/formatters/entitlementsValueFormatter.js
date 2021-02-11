import React from 'react';
import { Table as PfTable } from 'patternfly-react';
import { getEntitlementsDisplayValue } from '../../../scenes/Subscriptions/components/SubscriptionsTable/SubscriptionsTableHelpers.js';

export default (rawValue, additionalData) => {
  const { available, upstream_pool_id: upstreamPoolId, collapsible } = additionalData.rowData;
  const value = getEntitlementsDisplayValue({
    rawValue, available, collapsible, upstreamPoolId,
  });

  return (
    <PfTable.Cell>
      {value}
    </PfTable.Cell>
  );
};
