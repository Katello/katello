import React from 'react';
import PropTypes from 'prop-types';
import { TextContent, Text, TextVariants } from '@patternfly/react-core';

const InactiveText = ({ text }) => (
  <TextContent>
    <Text component={TextVariants.small}>{text}</Text>
  </TextContent>
);

InactiveText.propTypes = {
  text: PropTypes.string.isRequired,
};

export default InactiveText;
