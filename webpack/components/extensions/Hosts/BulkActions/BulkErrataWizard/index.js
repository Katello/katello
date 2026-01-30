import React from 'react';
import { Modal, ModalVariant } from '@patternfly/react-core';
import BulkErrataWizard from './BulkErrataWizard';
import { useBulkModalOpen } from '../bulkModalState';

const BulkErrataWizardModal = () => {
  const { isOpen, close: closeModal } = useBulkModalOpen('bulk-errata-wizard');

  return (
    <Modal
      width="60%"
      ouiaId="bulk-errata-wizard-modal"
      isOpen={isOpen}
      showClose={false}
      aria-label="Wizard modal"
      hasNoBodyWrapper
      variant={ModalVariant.medium}
    >
      <BulkErrataWizard isOpen={isOpen} closeModal={closeModal} />
    </Modal>
  );
};

export default BulkErrataWizardModal;
