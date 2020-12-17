import React from 'react';
import PropTypes from 'prop-types';
import SmartProxyContentTable from './SmartProxyContentTable';

const Content = ({ smartProxyId }) => (
  <SmartProxyContentTable smartProxyId={smartProxyId} />
);

Content.propTypes = {
  smartProxyId: PropTypes.number,
};

Content.defaultProps = {
  smartProxyId: null,
};

export default Content;
