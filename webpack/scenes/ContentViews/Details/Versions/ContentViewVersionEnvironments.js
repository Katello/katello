import React from 'react';
import PropTypes from 'prop-types';
import { Label, Flex, FlexItem } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import InactiveText from '../../components/InactiveText';

const ContentViewVersionEnvironments = ({ environments }) => {
  if (environments.length === 0) {
    return (
      <InactiveText text={__('No environments')} />
    );
  }

  return environments.map(env => (
    <React.Fragment key={env.id}>
      <Flex>
        <FlexItem>
          <Label isTruncated color="purple" href={`/lifecycle_environments/${env.id}`}>{env.name}</Label>
        </FlexItem>
        <FlexItem>
          <InactiveText text={` ${env.publish_date} ago`} /><br />
        </FlexItem>
      </Flex>
    </React.Fragment>));
};

ContentViewVersionEnvironments.propTypes = {
  environments: PropTypes.instanceOf(Array).isRequired,
};

export default ContentViewVersionEnvironments;
