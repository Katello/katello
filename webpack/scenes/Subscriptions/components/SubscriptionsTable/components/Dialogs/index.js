import React, { Fragment } from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import UpdateDialog from './UpdateDialog';
import UnsavedChangesDialog from './UnsavedChangesDialog';
import InputsErrorsDialog from './InputsErrorsDialog';
import DeleteDialog from './DeleteDialog';

const Dialogs = ({
  updateDialog, unsavedChangesDialog, inputsErrorsDialog, deleteDialog,
}) => (
  <Fragment>
    <UpdateDialog {...updateDialog} />
    <UnsavedChangesDialog {...unsavedChangesDialog} />
    <InputsErrorsDialog {...inputsErrorsDialog} />
    <DeleteDialog {...deleteDialog} />
  </Fragment>
);

Dialogs.propTypes = {
  updateDialog: PropTypes.shape(UpdateDialog.propTypes).isRequired,
  unsavedChangesDialog: PropTypes.shape(UnsavedChangesDialog.propTypes).isRequired,
  inputsErrorsDialog: PropTypes.shape(InputsErrorsDialog.propTypes).isRequired,
  deleteDialog: PropTypes.shape(DeleteDialog.propTypes).isRequired,
};

export default Dialogs;

