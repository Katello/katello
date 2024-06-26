import React, { useContext } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { Button } from '@patternfly/react-core';
import { WizardFooterWrapper, useWizardContext } from '@patternfly/react-core/next';
import { BulkErrataWizardContext } from './BulkErrataWizard';
import { dropdownOptions } from './04_Review';
import { errataInstallUrl } from '../../../HostDetails/Tabs/customizedRexUrlHelpers';
import { installErrata } from '../../../HostDetails/Tabs/RemoteExecutionActions';
import { useRexJobPolling } from '../../../HostDetails/Tabs/RemoteExecutionHooks';

export const BulkErrataReviewFooter = () => {
  const {
    finishButtonText,
    finishButtonLoading,
    setFinishButtonLoading,
    selectedRexOption,
    closeModal,
    errataBulkSelect: {
      fetchBulkParams: getErrataBulkParams,
      selectedCount: errataSelectedCount,
    },
    hostsBulkSelect: {
      fetchBulkParams: getHostsBulkParams,
      selectedCount: hostsSelectedCount,
    },
  } = useContext(BulkErrataWizardContext);

  const { goToStepById } = useWizardContext();

  let errataBulkParams = '';
  let hostsBulkParams = '';
  if (errataSelectedCount) errataBulkParams = getErrataBulkParams();
  if (hostsSelectedCount) hostsBulkParams = getHostsBulkParams();
  // Customized REX
  const [viaRex] = dropdownOptions;
  const customizedRexUrl = errataInstallUrl({
    hostSearch: hostsBulkParams,
    search: errataBulkParams,
  });

  const errataBulkInstallAction = () => installErrata({
    hostSearch: hostsBulkParams,
    search: errataBulkParams,
  });

  const {
    triggerJobStart: triggerBulkErrataInstall,
    isPolling: isBulkInstallInProgress,
  } = useRexJobPolling(errataBulkInstallAction);

  const handleFinishButtonClick = () => {
    setFinishButtonLoading(true);
    triggerBulkErrataInstall();
    closeModal();
  };

  const finishButton = (selectedRexOption === viaRex) ?
    (
      <Button
        key="bulk-errata-wizard-finish-button"
        ouiaId="bulk-errata-wizard-finish-button-via-rex"
        type="submit"
        variant="primary"
        className="pf-m-progress"
        isLoading={finishButtonLoading || isBulkInstallInProgress}
        isDisabled={finishButtonLoading || isBulkInstallInProgress}
        onClick={handleFinishButtonClick}
      >
        {finishButtonText}
      </Button>
    ) : (
      <Button
        key="bulk-errata-wizard-finish-button"
        ouiaId="bulk-errata-wizard-finish-button-via-customized-rex"
        component="a"
        isLoading={finishButtonLoading}
        isDisabled={finishButtonLoading}
        onClick={() => setFinishButtonLoading(true)}
        variant="primary"
        href={customizedRexUrl}
      >
        {finishButtonText}
      </Button>
    );

  return (
    <WizardFooterWrapper>
      {finishButton}
      <Button variant="secondary" onClick={() => goToStepById('mew-step-3')} isDisabled={finishButtonLoading} ouiaId="bulk-pkg-wiz-step4-back">
        {__('Back')}
      </Button>
      <Button variant="link" onClick={closeModal} isDisabled={finishButtonLoading} ouiaId="bulk-pkg-wiz-step4-cancel">
        {__('Cancel')}
      </Button>
    </WizardFooterWrapper>
  );
};

export default BulkErrataReviewFooter;
