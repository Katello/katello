import React from 'react';
import { EmptyState,
  EmptyStateBody,
  EmptyStateIcon,
  EmptyStateVariant,
  Bullseye,
  Title } from '@patternfly/react-core';
import PropTypes from 'prop-types';
import { CubeIcon, ExclamationCircleIcon } from '@patternfly/react-icons';
import { global_danger_color_200 as dangerColor } from '@patternfly/react-tokens';

const EmptyStateMessage = ({ title, body, error }) => (
  <Bullseye>
    <EmptyState variant={EmptyStateVariant.small}>
      {error ?
        <EmptyStateIcon icon={ExclamationCircleIcon} color={dangerColor.value} /> :
        <EmptyStateIcon icon={CubeIcon} />}
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
  title: PropTypes.string,
  body: PropTypes.string,
  error: PropTypes.oneOfType([
    PropTypes.shape({}),
    PropTypes.string,
  ]),
};

EmptyStateMessage.defaultProps = {
  title: 'Unable to retrieve information from the server.',
  body: 'Please check the server logs for more information',
  error: undefined,
};

export default EmptyStateMessage;
