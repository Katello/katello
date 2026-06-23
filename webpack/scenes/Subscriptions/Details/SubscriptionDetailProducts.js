import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { List, ListItem } from '@patternfly/react-core';
import './SubscriptionDetails.scss';

const SubscriptionDetailProducts = ({ subscriptionDetails }) => (
  <div>
    <h2>{__('Provided Products')}</h2>
    <List className="scrolld-list" isPlain>
      {subscriptionDetails.provided_products &&
        subscriptionDetails.provided_products.map(prod => (
          <ListItem key={prod.id}>{prod.name}</ListItem>
        ))}
    </List>
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
