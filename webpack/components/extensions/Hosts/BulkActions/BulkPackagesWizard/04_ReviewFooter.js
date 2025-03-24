import React, { useContext } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Button,
  WizardFooterWrapper,
  useWizardContext,
} from '@patternfly/react-core';

import { BulkPackagesWizardContext, INSTALL, UPGRADE, UPGRADE_ALL, REMOVE } from './BulkPackagesWizard';
import { dropdownOptions } from './04_Review';
import { katelloPackageInstallBySearchUrl, packagesUpdateUrl, katelloPackageRemoveBySearchUrl } from '../../../HostDetails/Tabs/customizedRexUrlHelpers';
import { installPackageBySearch, updatePackages, removePackagesBySearch } from '../../../HostDetails/Tabs/RemoteExecutionActions';
import { useRexJobPolling } from '../../../HostDetails/Tabs/RemoteExecutionHooks';

export const BulkPackagesReviewFooter = () => {
  const {
    finishButtonText,
    finishButtonLoading,
    setFinishButtonLoading,
    selectedRexOption,
    closeModal,
    packagesBulkSelect: {
      fetchBulkParams: getPackagesBulkParams,
      selectedCount: packagesSelectedCount,
    },
    hostsBulkSelect: {
      fetchBulkParams: getHostsBulkParams,
      selectedCount: hostsSelectedCount,
    },
    selectedAction,
  } = useContext(BulkPackagesWizardContext);

  const { goToStepById } = useWizardContext();

  let packagesBulkParams = '';
  let hostsBulkParams = '';
  if (packagesSelectedCount) packagesBulkParams = getPackagesBulkParams();
  if (hostsSelectedCount) hostsBulkParams = getHostsBulkParams();

  // Customized REX
  const [viaRex] = dropdownOptions;
  const packageRexUrls = {
    [INSTALL]: katelloPackageInstallBySearchUrl,
    [REMOVE]: katelloPackageRemoveBySearchUrl,
    [UPGRADE]: packagesUpdateUrl,
    [UPGRADE_ALL]: packagesUpdateUrl,
  };
  const getCustomizedRexUrl = packageRexUrls[selectedAction];
  const customizedRexUrl = getCustomizedRexUrl({
    hostSearch: hostsBulkParams,
    search: selectedAction === UPGRADE_ALL ? '' : packagesBulkParams,
  });

  // REX
  const packageBulkUpgradeAction = () => updatePackages({
    hostSearch: hostsBulkParams,
    search: selectedAction === UPGRADE_ALL ? '' : packagesBulkParams,
    descriptionFormat: selectedAction === UPGRADE_ALL ? __('Upgrade all packages') : undefined,
  });

  const {
    triggerJobStart: triggerBulkPackageUpgrade,
    isPolling: isBulkUpgradeInProgress,
  } = useRexJobPolling(packageBulkUpgradeAction);

  const packageBulkInstallAction = () => installPackageBySearch({
    hostSearch: hostsBulkParams,
    search: packagesBulkParams,
  });

  const packageBulkRemoveAction = () => removePackagesBySearch({
    hostSearch: hostsBulkParams,
    search: packagesBulkParams,
  });

  const {
    triggerJobStart: triggerBulkPackageRemove,
    isPolling: isBulkRemoveInProgress,
  } = useRexJobPolling(packageBulkRemoveAction);

  const {
    triggerJobStart: triggerBulkPackageInstall,
    isPolling: isBulkInstallInProgress,
  } = useRexJobPolling(packageBulkInstallAction);

  const handleFinishButtonClick = () => {
    setFinishButtonLoading(true);
    if ([UPGRADE_ALL, UPGRADE].includes(selectedAction)) {
      triggerBulkPackageUpgrade();
    }
    if (selectedAction === INSTALL) {
      triggerBulkPackageInstall();
    }
    if (selectedAction === REMOVE) {
      triggerBulkPackageRemove();
    }
    closeModal();
  };

  const isBulkActionInProgress = isBulkUpgradeInProgress ||
    isBulkInstallInProgress || isBulkRemoveInProgress;

  const finishButton = (selectedRexOption === viaRex) ?
    (
      <Button
        key="bulk-packages-wizard-finish-button"
        ouiaId="bulk-packages-wizard-finish-button-via-rex"
        type="submit"
        variant="primary"
        className="pf-m-progress"
        isLoading={finishButtonLoading || isBulkActionInProgress}
        isDisabled={finishButtonLoading || isBulkActionInProgress}
        onClick={handleFinishButtonClick}
      >
        {finishButtonText}
      </Button>
    ) : (
      <Button
        key="bulk-packages-wizard-finish-button"
        ouiaId="bulk-packages-wizard-finish-button-via-customized-rex"
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
      <Button variant="secondary" onClick={() => goToStepById('mpw-step-3')} isDisabled={finishButtonLoading} ouiaId="bulk-pkg-wiz-step4-back">
        {__('Back')}
      </Button>
      <Button variant="link" onClick={closeModal} isDisabled={finishButtonLoading} ouiaId="bulk-pkg-wiz-step4-cancel">
        {__('Cancel')}
      </Button>
    </WizardFooterWrapper>
  );
};

export default BulkPackagesReviewFooter;
