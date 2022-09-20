import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  DescriptionList,
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
  List,
  ListItem,
  Text,
  TextVariants,
} from '@patternfly/react-core';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import IsoDate from 'foremanReact/components/common/dates/IsoDate';
import CardTemplate from 'foremanReact/components/HostDetails/Templates/CardItem/CardTemplate';

export const RegisteredBy = ({ user, activationKeys }) => {
  if (user) {
    return (
      <DescriptionListDescription>{user}</DescriptionListDescription>
    );
  }
  return (
    <>
      <List isPlain>
        <Text component={TextVariants.h4} ouiaId="activation-key-text">
          {activationKeys.length > 1 ? __('Activation keys') : __('Activation key')}
        </Text>
        {activationKeys.map(key => (
          <ListItem key={key.id}>
            <a href={urlBuilder(`activation_keys/${key.id}`, '')}>{key.name}</a>
          </ListItem>
        ))}
      </List>
    </>
  );
};

RegisteredBy.propTypes = {
  user: PropTypes.string,
  activationKeys: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
  })),
};

RegisteredBy.defaultProps = {
  user: '',
  activationKeys: {},
};

const RegistrationCard = ({ isExpandedGlobal, hostDetails }) => {
  const subscriptionFacetAttributes
    = propsToCamelCase(hostDetails?.subscription_facet_attributes || {});
  const {
    registeredAt, registeredThrough, activationKeys, user,
  }
    = subscriptionFacetAttributes;
  const login = user?.login;
  if (!registeredAt) return null;
  return (
    <CardTemplate
      header={__('Registration details')}
      expandable
      masonryLayout
      isExpandedGlobal={isExpandedGlobal}
    >
      <DescriptionList isHorizontal>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Registered on')}</DescriptionListTerm>
          <DescriptionListDescription><IsoDate date={registeredAt} /></DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Registered by')}</DescriptionListTerm>
          <RegisteredBy user={login} activationKeys={activationKeys} />
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Registered through')}</DescriptionListTerm>
          <DescriptionListDescription>{registeredThrough}</DescriptionListDescription>
        </DescriptionListGroup>
      </DescriptionList>
    </CardTemplate>
  );
};

RegistrationCard.propTypes = {
  isExpandedGlobal: PropTypes.bool,
  hostDetails: PropTypes.shape({
    subscription_facet_attributes: PropTypes.shape({
      user: PropTypes.shape({
        login: PropTypes.string,
      }),
      registered_at: PropTypes.string,
      registered_through: PropTypes.string,
      activation_keys: PropTypes.arrayOf(PropTypes.shape({
        id: PropTypes.number,
        name: PropTypes.string,
      })),
    }),
  }),
};

RegistrationCard.defaultProps = {
  isExpandedGlobal: false,
  hostDetails: {},
};

export default RegistrationCard;
