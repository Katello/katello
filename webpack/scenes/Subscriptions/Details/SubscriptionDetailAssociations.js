import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'react-bootstrap';
import { translate as __ } from 'foremanReact/common/I18n';
import helpers from '../../../move_to_foreman/common/helpers.js';

const SubscriptionDetailAssociations = ({ subscriptionDetails }) => {
  const searchQuery = 'subscription_id="%s"'.replace('%s', subscriptionDetails.id);

  return (
    <div>
      <h2>{__('Associations')}</h2>
      <Table striped bordered condensed hover>
        <thead>
          <tr>
            <td><b>{__('Resource')}</b></td>
            <td><b>{__('Quantity')}</b></td>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>{__('Content Hosts')}</td>
            <td>
              <a href={helpers.urlWithSearch('content_hosts', searchQuery)}>
                {subscriptionDetails.host_count}
              </a>
            </td>
          </tr>
          <tr>
            <td>{__('Activation Keys')}</td>
            <td>
              <a href={helpers.urlWithSearch('activation_keys', searchQuery)}>
                {subscriptionDetails.activation_keys &&
                  subscriptionDetails.activation_keys.length}
              </a>
            </td>
          </tr>
        </tbody>
      </Table>
    </div>
  );
};

SubscriptionDetailAssociations.propTypes = {
  subscriptionDetails: PropTypes.shape({
    id: PropTypes.number,
    host_count: PropTypes.number,
    activation_keys: PropTypes.array,
  }).isRequired,
};

export default SubscriptionDetailAssociations;
