import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import { ListGroup, ListGroupItem } from '@theforeman/vendor/patternfly-react';
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
  subscriptionDetails: PropTypes.shape({}).isRequired,
};

export default SubscriptionDetailProducts;
