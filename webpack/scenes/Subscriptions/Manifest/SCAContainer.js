import React, { useState } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import SimpleContentAccess from './SimpleContentAccess';

const SCAContainer = (props) => {
  const {
    isSimpleContentAccessEnabled,
  } = props;
  const [enabled, setEnabled] = useState(isSimpleContentAccessEnabled);
  const infoMsgOverride = (enabled !== isSimpleContentAccessEnabled) || undefined;

  const enableSimpleContentAccess = () => {
    setEnabled(true);
  };
  const disableSimpleContentAccess = () => {
    setEnabled(false);
  };
  const getInfoMsg = () => {
    // State of the switch here reflects user clicks/intent, but submit button has NOT been clicked.
    if (enabled) { // SCA was initially disabled and user has toggled the switch to enable it
      return __('Change pending; click Submit to enable Simple Content Access and refresh your manifest.');
    }
    // SCA was initially enabled and user has toggled the switch to disable it
    return __('Change pending; click Submit to disable Simple Content Access and refresh your manifest.');
  };

  return (
    <SimpleContentAccess
      enableSimpleContentAccess={enableSimpleContentAccess}
      disableSimpleContentAccess={disableSimpleContentAccess}
      isSimpleContentAccessEnabled={enabled}
      canToggleSimpleContentAccess
      infoMessage={infoMsgOverride && getInfoMsg()}
      colWidths={{ left: 2, right: 4 }}
    />
  );
};

SCAContainer.propTypes = {
  isSimpleContentAccessEnabled: PropTypes.bool.isRequired,
};

export default SCAContainer;
