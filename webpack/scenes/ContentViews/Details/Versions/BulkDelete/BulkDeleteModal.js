import React, { useContext } from 'react';

import { translate as __ } from 'foremanReact/common/I18n';
import { PropTypes } from 'prop-types';
import { FormattedMessage } from 'react-intl';

import { Wizard } from '@patternfly/react-core';

import BulkDeleteContextWrapper, {
  BulkDeleteContext,
} from './BulkDeleteContextWrapper';
import {
  getVersionListString,
} from './BulkDeleteHelpers';
import bulkDeleteSteps from './bulkDeleteSteps';

const BulkDeleteModal = ({ versions, onClose }) => {
  const WizardWithContext = () => {
    const context = useContext(BulkDeleteContext);
    const versionList = getVersionListString(versions);
    const description =
      (<FormattedMessage
        id="bulk-delete-modal-title"
        values={{ versionList }}
        defaultMessage={versions.length === 1 ?
          __('Deleting version {versionList}') :
          __('Deleting versions: {versionList}')}
      />);

    return (
      <Wizard
        title={versions.length === 1 ?
          __('Delete version') :
          __('Delete versions')}
        description={description}
        steps={bulkDeleteSteps(context)}
        onGoToStep={({ id }) => context.setCurrentStep(id)}
        onNext={({ id }) => context.setCurrentStep(id)}
        onBack={({ id }) => context.setCurrentStep(id)}
        onClose={onClose}
        isOpen
      />);
  };

  return (
    <BulkDeleteContextWrapper {...{ versions, onClose }}>
      <WizardWithContext />
    </BulkDeleteContextWrapper>
  );
};

BulkDeleteModal.propTypes = {
  versions: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  onClose: PropTypes.func.isRequired,
};
export default BulkDeleteModal;
