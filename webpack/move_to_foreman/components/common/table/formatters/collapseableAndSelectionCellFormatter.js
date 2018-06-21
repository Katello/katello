import React from 'react';
import selectionCellFormatter from './selectionCellFormatter';
import CollapseSubscriptionGroupButton from '../components/CollapseSubscriptionGroupButton';

export default (collapseableController, selectionController, additionalData) => {
  const shouldShowCollapseButton = collapseableController.isCollapseable(additionalData);

  return selectionCellFormatter(
    selectionController,
    additionalData,
    shouldShowCollapseButton && (
      <CollapseSubscriptionGroupButton
        collapsed={collapseableController.isCollapsed(additionalData)}
        onClick={() => collapseableController.toggle(additionalData)}
      />
    ),
  );
};
