import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Bullseye,
  Title,
  EmptyState,
  EmptyStateIcon,
  Spinner,
} from '@patternfly/react-core';

const Loading = ({ size, showText }) => (
  <Bullseye>
    <EmptyState>
      <EmptyStateIcon size={size} variant="container" component={Spinner} />
      {showText && (
        <Title size={size} headingLevel="h4">
          {__('Loading')}
        </Title>)}
    </EmptyState>
  </Bullseye>
);

Loading.propTypes = {
  size: PropTypes.string,
  showText: PropTypes.bool,
};

Loading.defaultProps = {
  size: 'lg',
  showText: true,
};


export default Loading;
