import React from 'react';
import PropTypes from 'prop-types';
import { Grid, GridItem, Title } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import CdnConfigurationForm from './CdnConfigurationTab';

const CdnTabContent = ({ cdnConfiguration, contentCredentials, onUpdate }) => (
  <Grid hasGutter>
    <GridItem span={12}>
      <Title headingLevel="h3" size="lg" ouiaId="cdn-configuration-title">
        {__('CDN Configuration for Red Hat Content')}
      </Title>
    </GridItem>
    <GridItem span={12}>
      <CdnConfigurationForm
        cdnConfiguration={cdnConfiguration}
        contentCredentials={contentCredentials}
        onUpdate={onUpdate}
      />
    </GridItem>
  </Grid>
);

CdnTabContent.propTypes = {
  cdnConfiguration: PropTypes.shape({
    url: PropTypes.string,
    username: PropTypes.string,
    upstream_organization_label: PropTypes.string,
    ssl_ca_credential_id: PropTypes.number,
    password_exists: PropTypes.bool,
  }),
  contentCredentials: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
  })),
  onUpdate: PropTypes.func.isRequired,
};

CdnTabContent.defaultProps = {
  cdnConfiguration: {},
  contentCredentials: [],
};

export default CdnTabContent;
