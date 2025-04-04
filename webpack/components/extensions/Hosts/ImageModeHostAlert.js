import React from 'react';
import {
  Alert,
} from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';

const ImageModeHostAlert = () => (
  <Alert style={{ alignItems: 'center' }} className="margin-16-24" title={__('Package actions will be transient')} variant="info" ouiaId="image-mode-alert-info">
    <p>{__('Any updates to image mode host(s) will be lost on the next reboot.')}</p>
  </Alert>
);

export default ImageModeHostAlert;
