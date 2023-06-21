import React, { useState } from 'react';
import {
  Alert,
  AlertActionCloseButton,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

const KatelloAgentDeprecationAlert = () => {
  const [kAgentAlertShowing, setKAgentAlertShowing] = useState(true);

  return kAgentAlertShowing ? (
    <Alert
      variant="warning"
      className="katello-agent-deprecation-alert"
      ouiaId="katello-agent-deprecation-alert"
      isInline
      title={__('Katello-agent is deprecated and will be removed in Katello 4.10.')}
      actionClose={<AlertActionCloseButton ouiaId="katello-agent-alert-close-button" onClose={() => setKAgentAlertShowing(false)} />}
    />
  ) : null;
};

export default KatelloAgentDeprecationAlert;
