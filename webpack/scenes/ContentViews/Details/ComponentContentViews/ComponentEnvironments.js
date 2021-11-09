import React from 'react';
import PropTypes from 'prop-types';
import { Label, Flex, FlexItem } from '@patternfly/react-core';

const ComponentEnvironments = ({ environments }) => {
  const envList = environments.map(env =>
    (
      <FlexItem key={env.id} style={{ marginTop: '0.25em', marginBottom: '0.25em' }}>
        <Label color="purple" href={`/lifecycle_environments/${env.id}`} isTruncated>{`${env.name}`}</Label>
      </FlexItem>
    ));
  return (
    <Flex grow={{ default: 'grow' }} spaceItems={{ default: 'spaceItemsSm' }}>
      {envList}
    </Flex>
  );
};

ComponentEnvironments.propTypes = {
  environments: PropTypes.instanceOf(Array),
};

ComponentEnvironments.defaultProps = {
  environments: [],
};

export default ComponentEnvironments;

