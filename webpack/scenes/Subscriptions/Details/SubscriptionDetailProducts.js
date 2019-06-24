import React from 'react';
import PropTypes from 'prop-types';
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
    provided_products: PropTypes.array,
  }).isRequired,
};

export default SubscriptionDetailProducts;
