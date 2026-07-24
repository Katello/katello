import React from 'react';
import { Link } from 'react-router-dom';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { getEntitlementsDisplayValue } from './components/SubscriptionsTable/SubscriptionsTableHelpers';

const formatDate = (dateString) => {
  if (!dateString || dateString === 'NA') return '—';
  const date = new Date(dateString);
  if (Number.isNaN(date.getTime())) return '—';
  return date.toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' });
};

const subscriptionName = (rowData) => {
  if (rowData.collapsible) {
    return rowData.name;
  }
  return <Link to={urlBuilder('subscriptions', '', rowData.id)}>{rowData.name}</Link>;
};

const subscriptionType = (rowData) => {
  if (rowData.virt_only === false) {
    return __('Physical');
  }
  if (rowData.hypervisor) {
    const hypervisorLink = urlBuilder(`new/hosts/${rowData.hypervisor.id}`, '');
    return (
      <span>
        {__('Guests of')}
        {' '}
        <a href={hypervisorLink}>{rowData.hypervisor.name}</a>
      </span>
    );
  }
  if (rowData.unmapped_guest) {
    return __('Temporary');
  }
  return __('Virtual');
};

export const createSubscriptionsColumns = () => ({
  id: {
    title: __('Name'),
    wrapper: rowData => subscriptionName(rowData),
  },
  type: {
    title: __('Type'),
    wrapper: rowData => subscriptionType(rowData),
  },
  product_id: {
    title: __('SKU'),
    wrapper: ({ product_id: productId, upstream_pool_id: upstreamPoolId }) =>
      (upstreamPoolId ? productId : '—'),
  },
  contract_number: {
    title: __('Contract'),
    wrapper: ({ contract_number: contractNumber }) => contractNumber || '—',
  },
  start_date: {
    title: __('Start date'),
    wrapper: ({ start_date: startDate }) => formatDate(startDate),
  },
  end_date: {
    title: __('End date'),
    wrapper: ({ end_date: endDate }) => formatDate(endDate),
  },
  virt_who: {
    title: __('Requires virt-who'),
    wrapper: ({ virt_who: virtWho }) => {
      if (virtWho === null || virtWho === undefined) return '—';
      return virtWho ? __('True') : __('False');
    },
  },
  quantity: {
    title: __('Entitlements'),
    wrapper: rowData => getEntitlementsDisplayValue({
      quantity: rowData.quantity,
      collapsible: rowData.collapsible,
    }),
  },
  product_host_count: {
    title: __('Hosts'),
    wrapper: ({ product_host_count: hostCount }) => hostCount,
  },
});

export default createSubscriptionsColumns;
