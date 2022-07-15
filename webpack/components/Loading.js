import React from 'react';
import PropTypes from 'prop-types';
import {
  Bullseye,
  Title,
  EmptyState,
  EmptyStateIcon,
  Spinner,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

const Loading = ({ size, showText, loadingText }) => (
  <Bullseye>
    <EmptyState>
      <EmptyStateIcon size={size} variant="container" component={Spinner} />
      {showText && (
        <Title size={size} headingLevel="h4" ouiaId="loading-title">
          {loadingText || __('Loading')}
        </Title>)}
    </EmptyState>
  </Bullseye>
);

Loading.propTypes = {
  size: PropTypes.string,
  showText: PropTypes.bool,
  loadingText: PropTypes.string,
};

Loading.defaultProps = {
  size: 'lg',
  showText: true,
  loadingText: null,
};


export default Loading;
