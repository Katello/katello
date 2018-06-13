import React from 'react';
import PropTypes from 'prop-types';
import { Spinner } from 'patternfly-react';
import './LoadingState.scss';

const LoadingState = ({
  loading,
  loadingText,
  children,
}) => {
  if (loading) {
    return (
      <div className="loading-state">
        <Spinner loading={loading} size="lg" />
        <p>{loadingText}</p>
      </div>
    );
  }

  return children;
};

LoadingState.propTypes = {
  loading: PropTypes.bool,
  loadingText: PropTypes.string,
  children: PropTypes.node,
};

LoadingState.defaultProps = {
  loading: false,
  loadingText: __('Loading'),
  children: null,
};

export default LoadingState;
