import React from 'react';
import PropTypes from 'prop-types';

const SubscriptionDetailProducts = ({ subscriptionDetails }) => (
  <div>
    <h2>{__('Provided Products')}</h2>
    <ul>
      {subscriptionDetails.provided_products &&
        subscriptionDetails.provided_products.map(prod => (
          <li key={prod.id}>{prod.name}</li>
          ))}
    </ul>
  </div>
);

SubscriptionDetailProducts.propTypes = {
  subscriptionDetails: PropTypes.shape({}).isRequired,
};

export default SubscriptionDetailProducts;
