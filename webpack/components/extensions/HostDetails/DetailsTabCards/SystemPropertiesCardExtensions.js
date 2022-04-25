import React from 'react';
import PropTypes from 'prop-types';
import {
  DescriptionListGroup,
  DescriptionListTerm,
  DescriptionListDescription,
  ClipboardCopy,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

const SystemPropertiesCardExtensions = ({ hostDetails }) => {
  const subscriptionUuid = hostDetails?.subscription_facet_attributes?.uuid;
  if (!subscriptionUuid) return null;
  return (
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Subscription UUID')}</DescriptionListTerm>
      <DescriptionListDescription>
        <ClipboardCopy isBlock variant="inline-compact" clickTip={__('Copied to clipboard')}>
          {subscriptionUuid}
        </ClipboardCopy>
      </DescriptionListDescription>
    </DescriptionListGroup>
  );
};

SystemPropertiesCardExtensions.propTypes = {
  hostDetails: PropTypes.shape({
    subscription_facet_attributes: PropTypes.shape({
      uuid: PropTypes.string,
    }),
  }),
};

SystemPropertiesCardExtensions.defaultProps = {
  hostDetails: {},
};

export default SystemPropertiesCardExtensions;
