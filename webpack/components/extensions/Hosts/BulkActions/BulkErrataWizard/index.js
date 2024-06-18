import React from 'react';
import { Modal, ModalVariant } from '@patternfly/react-core';
import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';
import BulkErrataWizard from './BulkErrataWizard';

const BulkErrataWizardModal = () => {
  const { modalOpen: isOpen } = useForemanModal({ id: 'bulk-errata-wizard' });

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
      <BulkErrataWizard />
    </Modal>
  );
};

export default BulkErrataWizardModal;
