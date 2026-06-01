import React from 'react';
import PropTypes from 'prop-types';
import Content from './Content';
import useSmartProxyContentRefresh from './useSmartProxyContentRefresh';

const SmartProxyContentWithRefresh = ({ smartProxyId, organizationId }) => {
  useSmartProxyContentRefresh({ smartProxyId, organizationId });

  return (
    <Content smartProxyId={smartProxyId} organizationId={organizationId} />
  );
};

SmartProxyContentWithRefresh.propTypes = {
  smartProxyId: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string,
  ]).isRequired,
  organizationId: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string,
  ]),
};

SmartProxyContentWithRefresh.defaultProps = {
  organizationId: null,
};

export default SmartProxyContentWithRefresh;
