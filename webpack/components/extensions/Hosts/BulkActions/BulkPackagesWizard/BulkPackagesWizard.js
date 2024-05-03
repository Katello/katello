import React, { useState, createContext, useContext } from 'react';
import { Radio, Text, TextVariants, TextContent } from '@patternfly/react-core';
import { Wizard, WizardHeader, WizardStep } from '@patternfly/react-core/next';
import { translate as __ } from 'foremanReact/common/I18n';
import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';
import { useBulkSelect } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import { useTableIndexAPIResponse } from 'foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks';
import { HOSTS_API_PATH } from 'foremanReact/routes/Hosts/constants';
import HostReview from './03_HostReview';
import { BulkPackagesReview, dropdownOptions } from './04_Review';
import { BulkPackagesUpgradeTable, BulkPackagesInstallTable } from './02_BulkPackagesTable';
import { BulkPackagesReviewFooter } from './04_ReviewFooter';
import katelloApi from '../../../../../services/api';

export const UPGRADE_ALL = 'upgradeAll';
export const UPGRADE = 'upgrade';
export const INSTALL = 'install';

export const BulkPackagesWizardContext = createContext({});

export const useHostsBulkSelect = ({ initialSelectedHosts, modalIsOpen }) => {
  const defaultParams = { search: initialSelectedHosts };
  const apiOptions = { key: 'HOST_REVIEW' };
  const replacementResponse = !modalIsOpen ? { response: {} } : false;
  const hostsResponse = useTableIndexAPIResponse({
    replacementResponse, // don't fetch data if modal is closed
    apiUrl: `${HOSTS_API_PATH}?per_page=7`,
    apiOptions,
    defaultParams,
  });

  const {
    response: {
      results: hostsResults,
      ...hostsMetadata
    },
  } = hostsResponse;

  const { total, page, subtotal } = hostsMetadata;

  return {
    hostsBulkSelect: useBulkSelect({
      results: hostsResults,
      metadata: { total, page, selectable: subtotal },
      initialSearchQuery: initialSelectedHosts,
      initialSelectAllMode: true,
    }),
    hostsResponse,
    hostsMetadata,
  };
};

const BulkPackagesWizard = () => {
  const { modalOpen, setModalClosed: closeModal } = useForemanModal({ id: 'bulk-packages-wizard' });


  const [selectedAction, setSelectedAction] = useState(UPGRADE_ALL);

  const { selectedCount: initialSelectedHostCount, fetchBulkParams }
    = useContext(ForemanActionsBarContext);

  const [shouldValidateStep2, setShouldValidateStep2] = useState(false);
  const [shouldValidateStep3, setShouldValidateStep3] = useState(false);
  const [finishButtonLoading, setFinishButtonLoading] = useState(false);
  const [selectedRexOption, setSelectedRexOption] = useState(dropdownOptions[0]);
  const finishButtonText = selectedAction === 'install' ? __('Install') : __('Upgrade');
  const tableType = selectedAction === INSTALL ? 'install' : 'upgrade';

  const PACKAGES_URL = `${katelloApi.getApiUrl('/packages')}?distinct=true&per_page=7&include_permissions=true&packages_restrict_upgradable=${tableType === 'upgrade'}`;
  const apiOptions = { key: 'BULK_HOST_PACKAGES' };
  const replacementResponse = !modalOpen ? { response: {} } : false;
  const packagesResponse = useTableIndexAPIResponse({
    replacementResponse, // don't fetch data if modal is closed
    apiUrl: PACKAGES_URL,
    apiOptions,
  });

  const {
    response: {
      results: packagesResults,
      ...packagesMetadata
    },
  } = packagesResponse;

  const { total, page, subtotal } = packagesMetadata;

  const packagesBulkSelect = useBulkSelect({
    results: packagesResults,
    metadata: { total, page, selectable: subtotal },
    idColumn: 'name',
  });

  const hostsBulkSelect =
    useHostsBulkSelect({ initialSelectedHosts: fetchBulkParams(), modalIsOpen: modalOpen });

  // eslint-disable-next-line no-restricted-globals
  const selectionIsValid = count => count > 0 || isNaN(count);
  const packageSelectionIsValid =
    selectionIsValid(packagesBulkSelect.selectedCount) || selectedAction === UPGRADE_ALL;
  const hostSelectionIsValid = selectionIsValid(hostsBulkSelect.hostsBulkSelect.selectedCount);
  const step2Valid = shouldValidateStep2 ? packageSelectionIsValid : true;
  const step3Valid = shouldValidateStep3 ? hostSelectionIsValid : true;
  const step4Valid = hostSelectionIsValid && packageSelectionIsValid;

  const bulkPackagesWizardContextData = {
    selectedAction,
    finishButtonText,
    initialSelectedHostCount,
    setShouldValidateStep2,
    finishButtonLoading,
    setFinishButtonLoading,
    selectedRexOption,
    setSelectedRexOption,
    closeModal,
    packagesBulkSelect,
    packagesResults,
    packagesMetadata,
    packagesResponse,
    hostsBulkSelect: hostsBulkSelect.hostsBulkSelect,
  };
  return (
    <BulkPackagesWizardContext.Provider value={bulkPackagesWizardContextData}>
      <Wizard
        title="Manage packages wizard"
        header={<WizardHeader title={__('Manage packages')} onClose={closeModal} />}
      >
        <WizardStep
          name={__('Select action')}
          id="mpw-step-1"
          footer={{ onClose: closeModal }}
        >
          <TextContent>
            <Text ouiaId="mpw-step-1-header" component={TextVariants.h2}>
              {__('Select action')}
            </Text>
            <Text ouiaId="mpw-step-1-content" component={TextVariants.p}>
              {__('To manage packages, select an action.')}
            </Text>
          </TextContent>
          <div style={{ marginBottom: '1rem' }} />
          <div style={{ marginLeft: '1rem' }}>
            <Radio
              isChecked={selectedAction === UPGRADE_ALL}
              name="packageActionRadioGroup"
              onChange={() => setSelectedAction(UPGRADE_ALL)}
              label={__('Upgrade all packages')}
              id="r1-upgrade-all-packages"
              ouiaId="r1-upgrade-all-packages"
            />
            <Radio
              isChecked={selectedAction === UPGRADE}
              name="packageActionRadioGroup"
              onChange={() => setSelectedAction(UPGRADE)}
              label={__('Upgrade packages')}
              id="r2-upgrade-packages"
              ouiaId="r2-upgrade-packages"
            />
            <Radio
              isChecked={selectedAction === INSTALL}
              name="packageActionRadioGroup"
              onChange={() => setSelectedAction(INSTALL)}
              label={__('Install packages')}
              id="r3-install-packages"
              ouiaId="r3-install-packages"
            />
          </div>
        </WizardStep>
        <WizardStep
          name={selectedAction === INSTALL ? __('Install packages') : __('Upgrade packages')}
          id="mpw-step-2"
          isHidden={selectedAction === UPGRADE_ALL}
          footer={{ isNextDisabled: !step2Valid, onClose: closeModal }}
          status={step2Valid ? 'default' : 'error'}
        >
          {selectedAction === INSTALL ? (
            <BulkPackagesInstallTable modalIsOpen={modalOpen} />
          ) : (
            <BulkPackagesUpgradeTable modalIsOpen={modalOpen} />
          )}
        </WizardStep>
        <WizardStep
          name={__('Review hosts')}
          id="mpw-step-3"
          status={step3Valid ? 'default' : 'error'}
          footer={{ isNextDisabled: !step4Valid, onClose: closeModal }}
        >
          <HostReview
            key={modalOpen}
            selectedAction={selectedAction}
            hostsBulkSelect={hostsBulkSelect}
            setShouldValidateStep={setShouldValidateStep3}
          />
        </WizardStep>
        <WizardStep
          name={__('Review')}
          id="mpw-review-step"
          footer={<BulkPackagesReviewFooter />}
          isDisabled={!step4Valid}
        >
          <BulkPackagesReview />
        </WizardStep>
      </Wizard>
    </BulkPackagesWizardContext.Provider>
  );
};

export default BulkPackagesWizard;
