import React from 'react';
import PropTypes from 'prop-types';
import {
  Bullseye,
  Title,
  EmptyState,
  EmptyStateIcon,
  Spinner,
} from '@patternfly/react-core';

const Loading = ({ size }) => (
  <Bullseye>
    <EmptyState>
      <EmptyStateIcon variant="container" component={Spinner} />
      <Title size={size}>
        Loading
      </Title>
    </EmptyState>
  </Bullseye>
);

Loading.propTypes = {
  size: PropTypes.string,
};

Loading.defaultProps = {
  size: 'lg',
};


export default Loading;
