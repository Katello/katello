import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { List, ListItem } from '@patternfly/react-core';
import CardTemplate from 'foremanReact/components/HostDetails/Templates/CardItem/CardTemplate';

const InstalledProductsCard = ({ isExpandedGlobal, hostDetails }) => {
  const installedProducts = hostDetails?.subscription_facet_attributes?.installed_products;
  if (!installedProducts?.length) return null;
  return (
    <CardTemplate
      header={__('Installed products')}
      expandable
      masonryLayout
      isExpandedGlobal={isExpandedGlobal}
    >
      <List isPlain>
        {installedProducts.map(product => (
          <ListItem key={product.productId}>
            {product.productName}
          </ListItem>
        ))}
      </List>
    </CardTemplate>
  );
};

InstalledProductsCard.propTypes = {
  isExpandedGlobal: PropTypes.bool,
  hostDetails: PropTypes.shape({
    subscription_facet_attributes: PropTypes.shape({
      installed_products: PropTypes.arrayOf(PropTypes.shape({
        productId: PropTypes.string,
        productName: PropTypes.string,
      })),
    }),
  }),
};

InstalledProductsCard.defaultProps = {
  isExpandedGlobal: false,
  hostDetails: {},
};

export default InstalledProductsCard;
