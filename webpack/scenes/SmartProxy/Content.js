import React from 'react';
import PropTypes from 'prop-types';
import SmartProxyExpandableTable from './SmartProxyExpandableTable';

const Content = ({ smartProxyId, organizationId }) => (
  <SmartProxyExpandableTable smartProxyId={smartProxyId} organizationId={organizationId} />
);

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
