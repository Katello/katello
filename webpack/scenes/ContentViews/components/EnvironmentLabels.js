import React from 'react';
import { Label } from '@patternfly/react-core';

const EnvironmentLabels = (environments) => {
  const { environments: singleEnvironment } = environments || {};
  const { name } = singleEnvironment || {};
  switch (environments) {
  case Array:
    return environments.map(env => (
      <React.Fragment key={env.id} style={{ marginBottom: '5px' }}>
        <Label
          color="purple"
          isTruncated
        >{env.name}
        </Label>
      </React.Fragment>
    ));
  default:
    return (
      <React.Fragment>
        <Label color="purple" isTruncated>
          {name}
        </Label>
      </React.Fragment>
    );
  }
};

export default EnvironmentLabels;
