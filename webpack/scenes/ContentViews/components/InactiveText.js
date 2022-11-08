import React from 'react';
import PropTypes from 'prop-types';
import { TextContent, Text, TextVariants } from '@patternfly/react-core';

const InactiveText = props => (
  <TextContent>
    <Text
      ouiaId="inactive-text"
      component={TextVariants.small}
      style={{
        display: 'inline-flex', alignItems: 'center', margin: 0,
      }}
      {...props}
    >{props.text}
    </Text>
  </TextContent>
);

InactiveText.propTypes = {
  text: PropTypes.string.isRequired,
};

export default InactiveText;
