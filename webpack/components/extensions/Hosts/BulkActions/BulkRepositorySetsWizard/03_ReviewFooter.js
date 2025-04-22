import React, { useContext } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Button,
  WizardFooterWrapper,
  useWizardContext,
} from '@patternfly/react-core';
import { BulkRepositorySetsWizardContext } from './BulkRepositorySetsWizard';

export const BulkRepositorySetsReviewFooter = () => {
  const {
    pendingOverrides,
    // setPendingOverrides,
    finishButtonText,
    // initialSelectedHostCount,
    // shouldValidateStep1,
    // setShouldValidateStep1,
    // setShouldValidateStep2,
    // repoSetsSelectionIsValid,
    allStepsValid,
    // setRepoSetsParamsAndAPI,
    finishButtonLoading,
    setFinishButtonLoading,
    closeModal,
    // repoSetsBulkSelect,
    // repoSetsResults,
    // repoSetsMetadata,
    // repoSetsResponse,
    hostsBulkSelect,
  } = useContext(BulkRepositorySetsWizardContext);

  const { goToStepById } = useWizardContext();

  const handleFinishButtonClick = () => {
    setFinishButtonLoading(true);
    console.log(pendingOverrides);
    console.log(hostsBulkSelect.selectedCount);
    closeModal();
  };
  return (
    <WizardFooterWrapper>
      <Button
        key="bulk-repo-sets-wizard-finish-button"
        ouiaId="bulk-repo-sets-wizard-finish-button"
        type="submit"
        variant="primary"
        isLoading={finishButtonLoading}
        isDisabled={finishButtonLoading || !allStepsValid}
        onClick={handleFinishButtonClick}
      >
        {finishButtonText}
      </Button>
      <Button variant="secondary" onClick={() => goToStepById('brsw-step-2')} isDisabled={finishButtonLoading} ouiaId="bulk-reposets-wiz-step3-back">
        {__('Back')}
      </Button>
      <Button variant="link" onClick={closeModal} isDisabled={finishButtonLoading} ouiaId="bulk-repo-sets-wiz-step3-cancel">
        {__('Cancel')}
      </Button>
    </WizardFooterWrapper>
  );
};

export default BulkRepositorySetsReviewFooter;
