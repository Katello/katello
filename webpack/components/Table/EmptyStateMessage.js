import React from 'react';
import { EmptyState,
  EmptyStateBody,
  EmptyStateIcon,
  EmptyStateVariant,
  Bullseye,
  Title } from '@patternfly/react-core';
import PropTypes from 'prop-types';
import { CubeIcon, ExclamationCircleIcon, SearchIcon } from '@patternfly/react-icons';
import { global_danger_color_200 as dangerColor } from '@patternfly/react-tokens';

const KatelloEmptyStateIcon = ({ error, search, customIcon }) => {
  if (error) return <EmptyStateIcon icon={ExclamationCircleIcon} color={dangerColor.value} />;
  if (search) return <EmptyStateIcon icon={SearchIcon} />;
  if (customIcon) return <EmptyStateIcon icon={customIcon} />;
  return <EmptyStateIcon icon={CubeIcon} />;
};

const EmptyStateMessage = ({
  title, body, error, search, customIcon,
}) => (
  <Bullseye>
    <EmptyState variant={EmptyStateVariant.small}>
      <KatelloEmptyStateIcon error={!!error} search={search} customIcon={customIcon} />
      <Title headingLevel="h2" size="lg">
        {title}
      </Title>
      <EmptyStateBody>
        {body}
      </EmptyStateBody>
    </EmptyState>
  </Bullseye>
);

KatelloEmptyStateIcon.propTypes = {
  error: PropTypes.bool,
  search: PropTypes.bool,
  customIcon: PropTypes.elementType,
};

KatelloEmptyStateIcon.defaultProps = {
  error: false,
  search: false,
  customIcon: undefined,
};

EmptyStateMessage.propTypes = {
  title: PropTypes.string,
  body: PropTypes.string,
  error: PropTypes.oneOfType([
    PropTypes.shape({}),
    PropTypes.string,
  ]),
  search: PropTypes.bool,
  customIcon: PropTypes.elementType,
};

EmptyStateMessage.defaultProps = {
  title: 'Unable to connect',
  body: 'There was an error retrieving data from the server. Check your connection and try again.',
  error: undefined,
  search: false,
  customIcon: undefined,
};

export default EmptyStateMessage;
