import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

const RepositoriesExpansion = ({ cvId }) =>
  <div id={`cv-repositories-expansion-${cvId}`}>{__('Repositories')}</div>;

RepositoriesExpansion.propTypes = {
  cvId: PropTypes.number.isRequired,
};

export default RepositoriesExpansion;
