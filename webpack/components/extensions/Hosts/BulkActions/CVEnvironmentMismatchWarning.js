import React from 'react';
import { Alert } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

const CVEnvironmentMismatchWarning = () => (
  <Alert
    variant="warning"
    ouiaId="mismatch-cv-env-alert"
    isInline
    title={__('The selected hosts are not all in the same content view environment(s). Packages may not be available to all hosts. Review your host selection and remove hosts if necessary.')}
    style={{ marginBottom: '1rem' }}
  />
);

export default CVEnvironmentMismatchWarning;
