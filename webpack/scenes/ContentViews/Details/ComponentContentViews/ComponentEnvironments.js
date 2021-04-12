import React from 'react';
import PropTypes from 'prop-types';
import { Label } from '@patternfly/react-core';

const ComponentEnvironments = ({ environments }) => {
  const envLabels = environments.map(env =>
    <React.Fragment key={env.id}><Label color="blue" href={`/lifecycle_environments/${env.id}`}>{`${env.name}`}</Label> </React.Fragment>);
  return envLabels;
};

ComponentEnvironments.propTypes = {
  environments: PropTypes.instanceOf(Array).isRequired,
};

export default ComponentEnvironments;

