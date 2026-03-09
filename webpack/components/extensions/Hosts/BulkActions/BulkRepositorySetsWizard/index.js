import React from 'react';
import { Modal, ModalVariant } from '@patternfly/react-core';
import { useBulkModalOpen } from 'foremanReact/common/BulkModalStateHelper';
import BulkRepositorySetsWizard from './BulkRepositorySetsWizard';

const BulkRepositorySetsWizardModal = () => {
  const { isOpen } = useBulkModalOpen('bulk-repo-sets-wizard');

  return (
    <Modal
      ouiaId="bulk-repo-sets-wizard-modal"
      isOpen={isOpen}
      showClose={false}
      aria-label="Wizard modal"
      hasNoBodyWrapper
      variant={ModalVariant.large}
    >
      <BulkRepositorySetsWizard />
    </Modal>
  );
};

export default BulkRepositorySetsWizardModal;
