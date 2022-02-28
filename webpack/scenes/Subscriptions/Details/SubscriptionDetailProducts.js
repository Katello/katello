import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { ListGroup, ListGroupItem } from 'patternfly-react';
import './SubscriptionDetails.scss';

const SubscriptionDetailProducts = ({ subscriptionDetails }) => (
  <div>
    <h2>{__('Provided Products')}</h2>
    <ListGroup className="scrolld-list">
      {subscriptionDetails.provided_products &&
        subscriptionDetails.provided_products.map(prod => (
          <ListGroupItem key={prod.id}> {prod.name} </ListGroupItem>
        ))}
    </ListGroup>
  </div>
);

SubscriptionDetailProducts.propTypes = {
  subscriptionDetails: PropTypes.shape({
    // Disabling rule as existing code failed due to an eslint-plugin-react update
    // eslint-disable-next-line react/forbid-prop-types
    provided_products: PropTypes.array,
  }).isRequired,
};

export default SubscriptionDetailProducts;
