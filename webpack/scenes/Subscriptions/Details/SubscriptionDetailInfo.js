import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'react-bootstrap';
import { translate as __ } from 'foremanReact/common/I18n';
import subscriptionAttributes from './SubscriptionAttributes';
import subscriptionPurposeAttributes from './SubscriptionPurposeAttributes';

const SubscriptionDetailInfo = ({ subscriptionDetails }) => {
  const subscriptionLimits = (subDetails) => {
    const limits = [];
    if (subDetails.sockets) {
      limits.push(__('Sockets: %s').replace('%s', subDetails.sockets));
    }
    if (subDetails.cores) {
      limits.push(__('Cores: %s').replace('%s', subDetails.cores));
    }
    if (subDetails.ram) {
      limits.push(__('RAM: %s GB').replace('%s', subDetails.ram));
    }
    if (limits.length > 0) {
      return limits.join(', ');
    }
    return '';
  };

  const subscriptionDetailValue = (subDetails, key) => (subDetails[key] == null ? '' : String(subDetails[key]));

  const formatInstanceBased = (subDetails) => {
    if (subDetails.instance_multiplier == null ||
        subDetails.instance_multiplier === '' ||
        subDetails.instance_multiplier === 0) {
      return __('No');
    }
    return __('Yes');
  };

  return (
    <div>
      <h2>{__('Subscription Info')}</h2>
      <Table ouiaId="subscription-info-table">
        <tbody>
          {Object.keys(subscriptionAttributes).map(key => (
            <tr key={key}>
              <td><b>{__(subscriptionAttributes[key])}</b></td>
              <td>{subscriptionDetailValue(subscriptionDetails, key)}</td>
            </tr>
          ))}
          <tr>
            <td><b>{__('Limits')}</b></td>
            <td>{subscriptionLimits(subscriptionDetails)}</td>
          </tr>
          <tr>
            <td><b>{__('Instance-based')}</b></td>
            <td>{formatInstanceBased(subscriptionDetails)}</td>
          </tr>
        </tbody>
      </Table>
      <h2>{__('System Purpose')}</h2>
      <Table ouiaId="system-purpose-table">
        <tbody>
          {Object.keys(subscriptionPurposeAttributes).map(key => (
            <tr key={key}>
              <td><b>{__(subscriptionPurposeAttributes[key])}</b></td>
              <td>{subscriptionDetailValue(subscriptionDetails, key)}</td>
            </tr>
          ))}
        </tbody>
      </Table>
    </div>
  );
};

SubscriptionDetailInfo.propTypes = {
  subscriptionDetails: PropTypes.shape({}).isRequired,
};

export default SubscriptionDetailInfo;
