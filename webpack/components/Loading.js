import React from 'react';
import PropTypes from 'prop-types';
import {
  Bullseye,
  Title,
  EmptyState,
  EmptyStateIcon,
  Spinner,
  Skeleton,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

const Loading = ({
  size, showText, loadingText, skeleton,
}) => {
  if (skeleton) {
    return <Skeleton height="100%" />;
  }
  return (
    <Bullseye>
      <EmptyState>
        <EmptyStateIcon size={size} variant="container" component={Spinner} />
        {showText && (
        <Title size={size} headingLevel="h4" ouiaId="loading-title">
          {loadingText || __('Loading')}
        </Title>)}
      </EmptyState>
    </Bullseye>
  );
};

Loading.propTypes = {
  size: PropTypes.string,
  showText: PropTypes.bool,
  loadingText: PropTypes.string,
  skeleton: PropTypes.bool,
};

Loading.defaultProps = {
  size: 'lg',
  showText: true,
  loadingText: null,
  skeleton: false,
};


export default Loading;
