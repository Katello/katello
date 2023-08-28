import React from 'react';
import PropTypes from 'prop-types';
import SmartProxyContentTable from './SmartProxyContentTable';
import SmartProxyExpandableTable from './SmartProxyExpandableTable';

const Content = ({ smartProxyId }) => (
  <SmartProxyExpandableTable smartProxyId={smartProxyId} />
);

Content.propTypes = {
  smartProxyId: PropTypes.number,
};

Content.defaultProps = {
  smartProxyId: null,
};

export default Content;
