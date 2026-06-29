import React from 'react';
import PropTypes from 'prop-types';
import SmartProxyExpandableTable from './SmartProxyExpandableTable';
import useSmartProxyContentRefresh from './useSmartProxyContentRefresh';

const Content = ({ smartProxyId, organizationId }) => {
  useSmartProxyContentRefresh({ smartProxyId, organizationId });

  return (
    <SmartProxyExpandableTable smartProxyId={smartProxyId} organizationId={organizationId} />
  );
};

Content.propTypes = {
  smartProxyId: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string, // The API can sometimes return strings
  ]),
  organizationId: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string, // The API can sometimes return strings
  ]),
};

Content.defaultProps = {
  smartProxyId: null,
  organizationId: null,
};

export default Content;
