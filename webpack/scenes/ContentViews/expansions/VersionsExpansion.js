import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

const VersionsExpansion = ({ cvId }) => <div id={`cv-versions-expansion-${cvId}`}>{__('Versions')}</div>;

VersionsExpansion.propTypes = {
  cvId: PropTypes.number.isRequired,
};

export default VersionsExpansion;
