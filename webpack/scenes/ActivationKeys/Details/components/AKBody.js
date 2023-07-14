import React from 'react';
import {
  Grid,
  GridItem,
} from '@patternfly/react-core';
import PropTypes from 'prop-types';
import '../ActivationKeyDetails.scss';
import SystemPurposeCard from '../../../../components/extensions/HostDetails/Cards/SystemPurposeCard/SystemPurposeCard';


const AKBody = ({ akDetails }) => (
  <Grid className="ak-details-tab-page" hasGutter>
    <GridItem span={6}>
      <SystemPurposeCard akDetails={akDetails} />
    </GridItem>
  </Grid>
);

AKBody.propTypes = {
  akDetails: PropTypes.shape({
    name: PropTypes.string,
    maxHosts: PropTypes.number,
    description: PropTypes.string,
    unlimitedHosts: PropTypes.bool,
    usageCount: PropTypes.number,
  }),
};

AKBody.defaultProps = {
  akDetails: {},
};

export default AKBody;
