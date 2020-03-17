import React from 'react';
import {
  Bullseye,
  Title,
  EmptyState,
  EmptyStateIcon,
} from '@patternfly/react-core';

const Loading = () => {
  const Spinner = () => (
    <span className="pf-c-spinner" role="progressbar" aria-valuetext="Loading...">
      <span className="pf-c-spinner__clipper" />
      <span className="pf-c-spinner__lead-ball" />
      <span className="pf-c-spinner__tail-ball" />
    </span>
  );

  return (
    <Bullseye>
      <EmptyState>
        <EmptyStateIcon variant="container" component={Spinner} />
        <Title size="lg" data-testid="cv-loading-text">
          Loading
        </Title>
      </EmptyState>
    </Bullseye>
  );
};

export default Loading;
