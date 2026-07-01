import React from 'react';
import PropTypes from 'prop-types';
import { Card, CardTitle, CardBody, Grid, GridItem } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import SubscriptionDetailProduct from './SubscriptionDetailProduct';

const SubscriptionDetailProductContent = ({ productContent }) => {
  const listItems = productContent.results
    .map(product => ({
      index: product.id,
      title: product.name,
      availableContent: (
        product.available_content.map(c => (
          {
            enabled: c.enabled,
            ...c.content,
          }
        ))
      ),
    }))
    .filter(item => item.availableContent.length > 0);

  if (listItems.length > 0) {
    return (
      <Grid hasGutter>
        {listItems.map(({
          index,
          title,
          availableContent,
        }) => (
          <GridItem key={index} span={12}>
            <Card ouiaId={`product-content-card-${index}`}>
              <CardTitle>{title}</CardTitle>
              <CardBody>
                {availableContent.map(content => (
                  <SubscriptionDetailProduct key={content.id} content={content} />
                ))}
              </CardBody>
            </Card>
          </GridItem>
        ))}
      </Grid>
    );
  }

  return (
    <div>{__('No products are enabled.')}</div>
  );
};

SubscriptionDetailProductContent.propTypes = {
  productContent: PropTypes.shape({
    // Disabling rule as existing code failed due to an eslint-plugin-react update
    // eslint-disable-next-line react/forbid-prop-types
    results: PropTypes.array,
  }).isRequired,
};

export default SubscriptionDetailProductContent;
