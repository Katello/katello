import React from 'react';
import PropTypes from 'prop-types';
import {
  DescriptionListGroup,
  DescriptionListTerm,
  DescriptionListDescription,
  ClipboardCopy,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

export const SystemPropertiesCardSubscription = ({ hostDetails }) => {
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

SystemPropertiesCardSubscription.propTypes = {
  hostDetails: PropTypes.shape({
    subscription_facet_attributes: PropTypes.shape({
      uuid: PropTypes.string,
    }),
  }),
};

SystemPropertiesCardSubscription.defaultProps = {
  hostDetails: {},
};

export const SystemPropertiesCardTracer = ({ hostDetails }) => {
  const tracerStatus = hostDetails?.content_facet_attributes?.katello_tracer_installed;
  return (
    <DescriptionListGroup>
      <DescriptionListTerm>{__('Tracer')}</DescriptionListTerm>
      <DescriptionListDescription>
        {tracerStatus ? __('Installed') : __('Not installed')}
      </DescriptionListDescription>
    </DescriptionListGroup>
  );
};

SystemPropertiesCardTracer.propTypes = {
  hostDetails: PropTypes.shape({
    content_facet_attributes: PropTypes.shape({
      katello_tracer_installed: PropTypes.bool,
    }),
  }),
};

SystemPropertiesCardTracer.defaultProps = {
  hostDetails: {},
};
