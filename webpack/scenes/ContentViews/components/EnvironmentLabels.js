import React from 'react';
import { Label } from '@patternfly/react-core';

const EnvironmentLabels = (environments) => {
  const { environments: singleEnvironment, isDisabled } = environments || {};
  const { name } = singleEnvironment || {};
  const labelColor = isDisabled ? 'grey' : 'purple';
  switch (environments) {
  case Array:
    return environments.map(env => (
      <React.Fragment key={env.id} style={{ marginBottom: '5px' }}>
        <Label
          color={labelColor}
          isTruncated
        >{env.name}
        </Label>
      </React.Fragment>
    ));
  default:
    return (
      <React.Fragment>
        <Label color={labelColor} isTruncated>
          {name}
        </Label>
      </React.Fragment>
    );
  }
};

export default EnvironmentLabels;
