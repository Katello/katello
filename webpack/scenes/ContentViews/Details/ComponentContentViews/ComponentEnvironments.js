import React from 'react';
import PropTypes from 'prop-types';
import { Label } from '@patternfly/react-core';

const ComponentEnvironments = ({ environments }) => environments.map((env, index) => (
  <Label
    key={env.id}
    style={{ margin: `4px 0 4px ${index > 0 ? '4px' : '0'}` }}
    color="purple"
    href={`/lifecycle_environments/${env.id}`}
    isTruncated
  >
    {`${env.name}`}
  </Label>
));


ComponentEnvironments.propTypes = {
  environments: PropTypes.instanceOf(Array),
};

ComponentEnvironments.defaultProps = {
  environments: [],
};

export default ComponentEnvironments;

