import React from 'react';
import { Modal, ModalVariant } from '@patternfly/react-core';
import BulkPackagesWizard from './BulkPackagesWizard';
import { useBulkModalOpen } from '../bulkModalState';

const BulkPackagesWizardModal = () => {
  const { isOpen } = useBulkModalOpen('bulk-packages-wizard');

  return (
    <Modal
      width="60%"
      ouiaId="bulk-packages-wizard-modal"
      isOpen={isOpen}
      showClose={false}
      aria-label="Wizard modal"
      hasNoBodyWrapper
      variant={ModalVariant.medium}
    >
      <BulkPackagesWizard />
    </Modal>
  );
};

export default BulkPackagesWizardModal;
