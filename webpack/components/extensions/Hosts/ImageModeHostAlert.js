import React from 'react';
import PropTypes from 'prop-types';
import {
  Alert,
} from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';

const ImageModeHostAlert = ({ showPersistenceWarning }) => (
  <Alert style={{ alignItems: 'center' }} className="margin-16-24" title={__('Package persistence information')} variant="info" ouiaId="image-mode-alert-info">
    <p>{__('Any updates to image mode host(s) will be lost on the next reboot.')}</p>
    {showPersistenceWarning && (
      <p>{__('Package persistence data will be reported by a future version of subscription-manager.')}</p>
    )}
  </Alert>
);

ImageModeHostAlert.propTypes = {
  showPersistenceWarning: PropTypes.bool,
};

ImageModeHostAlert.defaultProps = {
  showPersistenceWarning: false,
};

export default ImageModeHostAlert;
