import React from 'react';
import { Modal, ModalVariant } from '@patternfly/react-core';
import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';
import BulkRepositorySetsWizard from './BulkRepositorySetsWizard';

const BulkRepositorySetsWizardModal = () => {
  const { modalOpen: isOpen } = useForemanModal({ id: 'bulk-repo-sets-wizard' });

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
