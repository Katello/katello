import React from 'react';
import PropTypes from 'prop-types';

const ActivationKeyDetails = ({ match }) => <div>ActivationKeyDetails { match?.params?.id } </div>;

export default ActivationKeyDetails;

ActivationKeyDetails.propTypes = {
  match: PropTypes.shape({
    params: PropTypes.shape({
      id: PropTypes.string,
    }),
  }),
};

ActivationKeyDetails.defaultProps = {
  match: {},
};
