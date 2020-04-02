import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

const EnvironmentsExpansion = ({ cvId }) => {
  const identifier = `cv-environments-expansion-${cvId}`;
  return (
    <React.Fragment>
      <div id={identifier} data-testid={identifier}>{__('Environments')}</div>
      <div>this should be showing but will be replaced by something else later</div>
    </React.Fragment>
  );
};

EnvironmentsExpansion.propTypes = {
  cvId: PropTypes.number.isRequired,
};

export default EnvironmentsExpansion;
