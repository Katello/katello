import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { MessageDialog } from 'patternfly-react';

const UnsavedChangesDialog = ({
  show, cancelEdit, showCancelConfirm,
}) => (
  <MessageDialog
    show={show}
    title={__('Editing Entitlements')}
    secondaryContent={__('You have unsaved changes. Do you want to exit without saving your changes?')}
    primaryActionButtonContent={__('Exit')}
    primaryAction={cancelEdit}
    secondaryActionButtonContent={__('Cancel')}
    secondaryAction={() => showCancelConfirm(false)}
    onHide={() => showCancelConfirm(false)}
  />);

UnsavedChangesDialog.propTypes = {
  show: PropTypes.bool.isRequired,
  cancelEdit: PropTypes.func.isRequired,
  showCancelConfirm: PropTypes.func.isRequired,
};

export default UnsavedChangesDialog;
