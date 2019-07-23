import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { MessageDialog } from 'patternfly-react';

const InputsErrorsDialog = ({
  show, showErrorDialog,
}) => (
  <MessageDialog
    show={show}
    title={__('Editing Entitlements')}
    secondaryContent={__('Some of your inputs contain errors. Please update them and save your changes again.')}
    primaryAction={() => showErrorDialog(false)}
    onHide={() => showErrorDialog(false)}
    primaryActionButtonContent="Ok"
  />);

InputsErrorsDialog.propTypes = {
  show: PropTypes.bool.isRequired,
  showErrorDialog: PropTypes.func.isRequired,
};

export default InputsErrorsDialog;
