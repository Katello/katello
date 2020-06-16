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

const KatelloEmptyStateIcon = ({ error, search }) => {
  if (error) return <EmptyStateIcon icon={ExclamationCircleIcon} color={dangerColor.value} />;
  if (search) return <EmptyStateIcon icon={SearchIcon} />;
  return <EmptyStateIcon icon={CubeIcon} />;
};

const EmptyStateMessage = ({
  title, body, error, search,
}) => (
  <Bullseye>
    <EmptyState variant={EmptyStateVariant.small}>
      <KatelloEmptyStateIcon error={!!error} search={search} />
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
};

KatelloEmptyStateIcon.defaultProps = {
  error: false,
  search: false,
};

EmptyStateMessage.propTypes = {
  title: PropTypes.string,
  body: PropTypes.string,
  error: PropTypes.oneOfType([
    PropTypes.shape({}),
    PropTypes.string,
  ]),
  search: PropTypes.bool,
};

EmptyStateMessage.defaultProps = {
  title: 'Unable to connect',
  body: 'There was an error retrieving data from the server. Check your connection and try again.',
  error: undefined,
  search: false,
};

export default EmptyStateMessage;
