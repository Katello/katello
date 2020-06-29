import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
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
  updateDialog: PropTypes.shape({}).isRequired,
  unsavedChangesDialog: PropTypes.shape({}).isRequired,
  inputsErrorsDialog: PropTypes.shape({}).isRequired,
  deleteDialog: PropTypes.shape({}).isRequired,
};

export default Dialogs;

