import React, { useContext } from 'react';
import { useDispatch } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Button,
  WizardFooterWrapper,
  useWizardContext,
} from '@patternfly/react-core';
import { BulkRepositorySetsWizardContext } from './BulkRepositorySetsWizard';
import { bulkUpdateHostContentOverrides } from './actions';
import { pendingOverrideToApiParamItem } from './helpers';

export const BulkRepositorySetsReviewFooter = () => {
  const {
    pendingOverrides,
    finishButtonText,
    allStepsValid,
    finishButtonLoading,
    setFinishButtonLoading,
    closeModal,
    hostsBulkSelect,
  } = useContext(BulkRepositorySetsWizardContext);

  const { goToStepById } = useWizardContext();
  const dispatch = useDispatch();

  const overridesEntries = Object.entries(pendingOverrides);
  const apiParams = overridesEntries
    .map(([repoLabel, value]) => pendingOverrideToApiParamItem({ repoLabel, value }))
    .filter(item => item);

  const saveContentOverrides = () => {
    const requestBody = {
      included: {
        search: hostsBulkSelect.fetchBulkParams(),
      },
      content_overrides: apiParams,
    };
    dispatch(bulkUpdateHostContentOverrides(
      requestBody,
      closeModal, closeModal,
    ));
  };

  const handleFinishButtonClick = () => {
    setFinishButtonLoading(true);
    saveContentOverrides();
    closeModal();
  };
  return (
    <WizardFooterWrapper>
      <Button variant="secondary" onClick={() => goToStepById('brsw-step-2')} isDisabled={finishButtonLoading} ouiaId="bulk-reposets-wiz-step3-back">
        {__('Back')}
      </Button>
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
      <Button variant="link" onClick={closeModal} isDisabled={finishButtonLoading} ouiaId="bulk-repo-sets-wiz-step3-cancel">
        {__('Cancel')}
      </Button>
    </WizardFooterWrapper>
  );
};

export default BulkRepositorySetsReviewFooter;
