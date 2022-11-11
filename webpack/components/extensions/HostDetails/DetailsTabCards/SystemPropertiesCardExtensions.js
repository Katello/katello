import React from 'react';
import PropTypes from 'prop-types';
import {
  DescriptionListGroup,
  DescriptionListTerm,
  DescriptionListDescription,
  ClipboardCopy,
  Label,
} from '@patternfly/react-core';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';

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

export const SystemPropertiesCardVirtualization = ({ hostDetails }) => {
  if (!hostDetails?.subscription_facet_attributes) return null;

  const {
    virtualGuests,
    hypervisor,
    virtualHost,
  } = propsToCamelCase(hostDetails.subscription_facet_attributes);
  const virtualGuestIds = `name ^ (${virtualGuests.map(guest => guest.name).join(', ')})`;

  return (
    <>
      {hypervisor &&
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Virtual guests')}</DescriptionListTerm>
          <DescriptionListDescription>
            <a href={`/hosts?search=${encodeURI(virtualGuestIds)}`}>
              <Label color="blue" className="virtual-guests-label">
                {sprintf(__('%s guests'), virtualGuests.length)}
              </Label>
            </a>
          </DescriptionListDescription>
        </DescriptionListGroup>
      }
      {virtualHost &&
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Virtual host')}</DescriptionListTerm>
          <DescriptionListDescription>
            <a href={`/new/hosts/${virtualHost.name}`}>
              {virtualHost.name}
            </a>
          </DescriptionListDescription>
        </DescriptionListGroup>
      }
    </>
  );
};

SystemPropertiesCardVirtualization.propTypes = {
  hostDetails: PropTypes.shape({
    subscription_facet_attributes: PropTypes.shape({
      virtual_guests: PropTypes.arrayOf(PropTypes.shape({})),
      hypervisor: PropTypes.bool,
      virtual_host: PropTypes.shape({
        id: PropTypes.number,
        name: PropTypes.string,
      }),
    }),
  }),
};

SystemPropertiesCardVirtualization.defaultProps = {
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
