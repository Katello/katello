import React from 'react';
import PropTypes from 'prop-types';
import { Label } from '@patternfly/react-core';

const EnvironmentLabels = environments => environments.map(env =>
  <React.Fragment key={env.id}><Label color="purple" href={`/lifecycle_environments/${env.id}`}>{`${env.name}`}</Label></React.Fragment>);

EnvironmentLabels.propTypes = {
  environments: PropTypes.instanceOf(Array),
};

EnvironmentLabels.defaultProps = {
  environments: [],
};

export default EnvironmentLabels;
