import React from 'react';
import { EmptyState,
  EmptyStateBody,
  EmptyStateIcon,
  EmptyStateVariant,
  Bullseye,
  Title } from '@patternfly/react-core';
import PropTypes from 'prop-types';
import { CubeIcon } from '@patternfly/react-icons';

const EmptyStateMessage = ({ title, body }) => (
  <Bullseye>
    <EmptyState variant={EmptyStateVariant.small}>
      <EmptyStateIcon icon={CubeIcon} />
      <Title headingLevel="h2" size="lg">
        {title}
      </Title>
      <EmptyStateBody>
        {body}
      </EmptyStateBody>
    </EmptyState>
  </Bullseye>
);

EmptyStateMessage.propTypes = {
  title: PropTypes.string.isRequired,
  body: PropTypes.string.isRequired,
};

export default EmptyStateMessage;
