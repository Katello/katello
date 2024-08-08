import { translate as __ } from 'foremanReact/common/I18n';


const getMaxQuantity = (subscription, upstreamAvailable) => {
  if (upstreamAvailable === -1) {
    return upstreamAvailable;
  }
  return upstreamAvailable + subscription.quantity;
};

const buildTableRow = (subscription, availableQuantities, updatedQuantity) => {
  const upstreamAvailableLoaded = !!availableQuantities;
  const upstreamAvailable = upstreamAvailableLoaded
    ? availableQuantities[subscription.id]
    : null;

  let maxQuantity;
  if (upstreamAvailableLoaded) {
    maxQuantity = getMaxQuantity(subscription, upstreamAvailable);
  }

  const baseSubscription = {
    ...subscription,
    upstreamAvailable,
    upstreamAvailableLoaded,
    maxQuantity,
  };

  if (updatedQuantity[subscription.id]) {
    return {
      ...baseSubscription,
      entitlementsChanged: true,
      quantity: updatedQuantity[subscription.id],
    };
  }

  return baseSubscription;
};

const buildTableCollapseRow = (subscriptionGroup) => {
  const first = subscriptionGroup.subscriptions[0];
  const heading = {
    id: first.product_id,
    collapsible: true,
    contract_number: 'NA',
    start_date: 'NA',
    end_date: 'NA',
    consumed: 'NA',
    product_id: first.product_id,
    name: first.name,
    virt_only: first.virt_only,
    hypervisor: first.hypervisor,
    product_host_count: 'NA',
  };
  return heading;
};

const buildTableRowsFromGroup = (subscriptionGroup, availableQuantities, updatedQuantity) => {
  const { open, subscriptions } = subscriptionGroup;

  if (subscriptions.length > 1) {
    const rows = [];
    rows.push(buildTableCollapseRow(subscriptionGroup));
    if (open) {
      subscriptions.forEach(sub =>
        rows.push(buildTableRow(sub, availableQuantities, updatedQuantity)));
    }
    return rows;
  }
  // build row only for the first subscription in the group
  const [firstSubscription] = subscriptions;
  return [buildTableRow(firstSubscription, availableQuantities, updatedQuantity)];
};

export const buildTableRows = (groupedSubscriptions, availableQuantities, updatedQuantity) => {
  const rows = [];
  Object.values(groupedSubscriptions).forEach(subscriptionGroup =>
    rows.push(...buildTableRowsFromGroup(subscriptionGroup, availableQuantities, updatedQuantity)));

  return rows;
};

export const groupSubscriptionsByProductId = (
  { results: subscriptions },
  prevGroupedSubscriptions,
) => {
  const grouped = {};

  subscriptions.forEach((subscription) => {
    if (grouped[subscription.product_id] === undefined) {
      const prevOpenState = prevGroupedSubscriptions?.[subscription.product_id]?.open || false;
      grouped[subscription.product_id] = {
        open: prevOpenState,
        subscriptions: [],
      };
    }

    grouped[subscription.product_id].subscriptions.unshift(subscription);
  });

  return grouped;
};

export const buildPools = updatedQuantity =>
  Object.entries(updatedQuantity).map(([id, quantity]) => ({
    id,
    quantity,
  }));

export const getEntitlementsDisplayValue = ({
  rawValue, available, collapsible, upstreamPoolId,
}) => {
  if (collapsible) {
    return __('NA');
  }
  if ((available && available < 0) || !upstreamPoolId) {
    return (
      available < 0 ? __('Unlimited') : available
    );
  }
  return rawValue;
};
