import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

const DetailsExpansion = ({ cvId }) => <div id={`cv-details-expansion-${cvId}`}>{__('Details')}</div>;

DetailsExpansion.propTypes = {
  cvId: PropTypes.number.isRequired,
};

export default DetailsExpansion;
