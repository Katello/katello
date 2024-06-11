import React from 'react';
import { Modal, ModalVariant } from '@patternfly/react-core';
import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';
import BulkPackagesWizard from './BulkPackagesWizard';

const BulkPackagesWizardModal = () => {
  const { modalOpen: isOpen } = useForemanModal({ id: 'bulk-packages-wizard' });

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
