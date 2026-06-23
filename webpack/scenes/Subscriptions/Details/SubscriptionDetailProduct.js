import React from 'react';
import PropTypes from 'prop-types';
import { Grid, GridItem } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

const SubscriptionDetailProduct = ({ content }) => (
  <Grid hasGutter key={content.id}>
    <GridItem span={12}>
      <u>{content.name}</u>
    </GridItem>
    <GridItem span={3}>{__('Content Download URL')}</GridItem>
    <GridItem span={9}>{content.content_url}</GridItem>
    <GridItem span={3}>{__('GPG Key URL')}</GridItem>
    <GridItem span={9}>{content.gpg_url}</GridItem>
    <GridItem span={3}>{__('Repo Type')}</GridItem>
    <GridItem span={9}>{content.type}</GridItem>
    <GridItem span={3}>{__('Enabled')}</GridItem>
    <GridItem span={9}>{content.enabled ? __('yes') : __('no')}</GridItem>
  </Grid>
);

SubscriptionDetailProduct.propTypes = {
  content: PropTypes.shape({
    id: PropTypes.string,
    name: PropTypes.string,
    enabled: PropTypes.bool,
    content_url: PropTypes.string,
    gpg_url: PropTypes.string,
    type: PropTypes.string,
    enable: PropTypes.bool,
  }).isRequired,
};

export default SubscriptionDetailProduct;
