import React from 'react';

const LoadingSpinner = ({ children, isLoading }) => {
  let response = children;

  if (isLoading) {
    response = (<div className="spinner spinner-lg" />);
  }

  return response;
};

export default LoadingSpinner;
