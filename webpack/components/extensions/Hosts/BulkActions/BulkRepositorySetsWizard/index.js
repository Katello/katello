import React from 'react';
import { Modal, ModalVariant } from '@patternfly/react-core';
import BulkRepositorySetsWizard from './BulkRepositorySetsWizard';
import { useBulkModalOpen } from '../bulkModalState';

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
