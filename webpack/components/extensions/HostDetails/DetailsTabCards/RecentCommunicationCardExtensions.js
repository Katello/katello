import React from 'react';
import PropTypes from 'prop-types';
import RelativeDateTime from 'foremanReact/components/common/dates/RelativeDateTime';
import {
  DescriptionListGroup,
  DescriptionListTerm,
  DescriptionListDescription,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

const RecentCommunicationCardExtensions = ({ hostDetails }) => {
  const { subscription_facet_attributes: subscriptionFacetAttributes } = hostDetails;
  if (!Object.keys(subscriptionFacetAttributes ?? {}).includes('last_checkin')) return null;
  const lastCheckin = subscriptionFacetAttributes?.last_checkin;
  return (
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Last check-in:')}</DescriptionListTerm>
      <DescriptionListDescription>
        <RelativeDateTime date={lastCheckin} defaultValue={__('Never')} />
      </DescriptionListDescription>
    </DescriptionListGroup>
  );
};

RecentCommunicationCardExtensions.propTypes = {
  hostDetails: PropTypes.shape({
    subscription_facet_attributes: PropTypes.shape({
      last_checkin: PropTypes.string,
    }),
  }),
};

RecentCommunicationCardExtensions.defaultProps = {
  hostDetails: {},
};

export default RecentCommunicationCardExtensions;
