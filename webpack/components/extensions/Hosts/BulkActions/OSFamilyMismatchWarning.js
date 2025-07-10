import React from 'react';
import { Alert } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

const OSFamilyMismatchWarning = () => (
  <Alert
    variant="danger"
    ouiaId="mismatch-os-family-alert"
    isInline
    title={__('The selected hosts are in different OS families, for example, Debian and RedHat. Select hosts that belong to one OS family. Review your host selection and remove hosts if necessary.')}
    style={{ marginBottom: '1rem' }}
  />
);

export default OSFamilyMismatchWarning;
