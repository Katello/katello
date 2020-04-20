import React from 'react';
import {
  Bullseye,
  Title,
  EmptyState,
  EmptyStateIcon,
  Spinner,
} from '@patternfly/react-core';

const Loading = () => (
  <Bullseye>
    <EmptyState>
      <EmptyStateIcon variant="container" component={Spinner} />
      <Title size="lg">
        Loading
      </Title>
    </EmptyState>
  </Bullseye>
);

export default Loading;
