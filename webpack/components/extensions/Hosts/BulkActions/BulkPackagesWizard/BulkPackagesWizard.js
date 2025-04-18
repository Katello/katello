import React, { useState, createContext, useContext } from 'react';
import {
  Radio,
  Text,
  TextVariants,
  TextContent,
  Alert,
  Wizard,
  WizardHeader,
  WizardStep,
} from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';
import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';
import { useBulkSelect } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import { useTableIndexAPIResponse } from 'foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks';
import { STATUS } from 'foremanReact/constants';
import { HOSTS_API_PATH } from 'foremanReact/routes/Hosts/constants';
import HostReview from '../HostReview';
import { BulkPackagesReview, dropdownOptions } from './04_Review';
import { BulkPackagesUpgradeTable, BulkPackagesInstallTable, BulkPackagesRemoveTable } from './02_BulkPackagesTable';
import { BulkPackagesReviewFooter } from './04_ReviewFooter';
import katelloApi, { foremanApi } from '../../../../../services/api';
import CVEnvironmentMismatchWarning from '../CVEnvironmentMismatchWarning';
import OSFamilyMismatchWarning from '../OSFamilyMismatchWarning';
import BULK_ACTIONS_OSFAMILY from '../BulkActionsConstants';

export const UPGRADE_ALL = 'upgradeAll';
export const UPGRADE = 'upgrade';
export const INSTALL = 'install';
export const REMOVE = 'remove';

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

export const getPackagesUrl = (selectedAction, osFamily) => {
  if (osFamily === BULK_ACTIONS_OSFAMILY.INVALID) { return ''; }
  if (selectedAction === REMOVE) {
    return `${foremanApi.getApiUrl(`/hosts/host_${osFamily}/installed_${osFamily}`)}?per_page=7&include_permissions=true`;
  }

  return `${katelloApi.getApiUrl(`/${osFamily}/thindex`)}?per_page=7&include_permissions=true&packages_restrict_upgradable=${selectedAction === 'upgrade'}`;
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
  const packageActionsNames = {
    install: __('Install packages'), remove: __('Remove packages'), upgrade: __('Upgrade packages'), upgradeAll: __('Upgrade packages'),
  };


  const initialSelectedHosts = fetchBulkParams();

  const hostsBulkSelect =
    useHostsBulkSelect({ initialSelectedHosts, modalIsOpen: modalOpen });

  const currentlySelectedHosts =
    hostsBulkSelect?.hostsResponse?.response?.results?.filter(host =>
      !hostsBulkSelect.hostsBulkSelect.exclusionSet.has(host.id));
  const OSFamilyMismatch =
    selectedAction !== UPGRADE_ALL && currentlySelectedHosts?.length > 1 &&
    currentlySelectedHosts?.some(host =>
      host.operatingsystem_family !== currentlySelectedHosts[0].operatingsystem_family);
  const CVEnvMismatch =
    !OSFamilyMismatch &&
    selectedAction !== UPGRADE_ALL && currentlySelectedHosts?.length > 1 &&
    currentlySelectedHosts?.some(host =>
      host.content_facet_attributes?.content_view_environment_labels !==
      currentlySelectedHosts[0].content_facet_attributes?.content_view_environment_labels);

  const getOSFamily = () => {
    if (OSFamilyMismatch || currentlySelectedHosts === undefined) { return BULK_ACTIONS_OSFAMILY.INVALID; } else if (currentlySelectedHosts[0]?.operatingsystem_family === 'Debian') { return BULK_ACTIONS_OSFAMILY.DEBIAN; }

    return BULK_ACTIONS_OSFAMILY.REDHAT;
  };

  const getContentWarning = () => {
    if (OSFamilyMismatch) {
      return (<OSFamilyMismatchWarning />);
    } else if (CVEnvMismatch) {
      return (<CVEnvironmentMismatchWarning />);
    }
    return (<></>);
  };

  const finishButtonTextValues = {
    install: __('Install'), remove: __('Remove'), upgrade: __('Upgrade'), upgradeAll: __('Upgrade'),
  };
  const finishButtonText = finishButtonTextValues[selectedAction];
  const PACKAGES_URL = getPackagesUrl(selectedAction, getOSFamily());
  const apiOptions = { key: 'BULK_HOST_PACKAGES' };
  const replacementResponse = !modalOpen || OSFamilyMismatch ? { response: {} } : false;
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
    status: packagesStatus,
  } = packagesResponse;

  const { total, page, subtotal } = packagesMetadata;

  const packagesBulkSelect = useBulkSelect({
    results: packagesResults,
    metadata: { total, page, selectable: subtotal },
    idColumn: 'name',
  });

  // eslint-disable-next-line no-restricted-globals
  const selectionIsValid = count => count > 0 || isNaN(count);
  const packagesResultsPresent = packagesResults?.length > 0;
  const packageSelectionIsValid =
    selectionIsValid(packagesBulkSelect.selectedCount) || selectedAction === UPGRADE_ALL;
  const hostSelectionIsValid = selectionIsValid(hostsBulkSelect.hostsBulkSelect.selectedCount);
  let step2Valid = shouldValidateStep2 ? packageSelectionIsValid : true;
  if (!packagesResultsPresent) step2Valid = false;
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

  const packageActions = () => {
    switch (selectedAction) {
    case INSTALL:
      return (
        <BulkPackagesInstallTable
          osFamily={getOSFamily()}
          OSFamilyMismatch={OSFamilyMismatch}
          warningBanner={getContentWarning()}
          modalIsOpen={modalOpen}
        />
      );
    case REMOVE:
      return (
        <BulkPackagesRemoveTable
          osFamily={getOSFamily()}
          OSFamilyMismatch={OSFamilyMismatch}
          warningBanner={getContentWarning()}
          modalIsOpen={modalOpen}
        />
      );
    default:
      return (
        <BulkPackagesUpgradeTable
          osFamily={getOSFamily()}
          OSFamilyMismatch={OSFamilyMismatch}
          warningBanner={getContentWarning()}
          modalIsOpen={modalOpen}
        />
      );
    }
  };

  return (
    <BulkPackagesWizardContext.Provider value={bulkPackagesWizardContextData}>
      <Wizard
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
          {getContentWarning()}
          {packagesStatus === STATUS.RESOLVED && !packagesResultsPresent && !OSFamilyMismatch && (
            <Alert
              ouiaId="no-packages-found-alert"
              variant="info"
              isInline
              title={__('No upgradable packages found.')}
              style={{ marginBottom: '1rem' }}
            />
          )}
          <div style={{ marginBottom: '1rem' }} />
          <div style={{ marginLeft: '1rem' }}>
            <Radio
              isChecked={selectedAction === UPGRADE_ALL}
              name="packageActionRadioGroup"
              onChange={() => setSelectedAction(UPGRADE_ALL)}
              label={__('Upgrade all packages')}
              id="r1-upgrade-all-packages"
              ouiaId="r1-upgrade-all-packages"
              style={{ marginTop: '0rem' }}
            />
            <Radio
              isChecked={selectedAction === UPGRADE}
              name="packageActionRadioGroup"
              onChange={() => setSelectedAction(UPGRADE)}
              label={__('Upgrade packages')}
              id="r2-upgrade-packages"
              ouiaId="r2-upgrade-packages"
              style={{ marginTop: '0rem' }}
            />
            <Radio
              isChecked={selectedAction === INSTALL}
              name="packageActionRadioGroup"
              onChange={() => setSelectedAction(INSTALL)}
              label={__('Install packages')}
              id="r3-install-packages"
              ouiaId="r3-install-packages"
              style={{ marginTop: '0rem' }}
            />
            <Radio
              isChecked={selectedAction === REMOVE}
              name="packageActionRadioGroup"
              onChange={() => setSelectedAction(REMOVE)}
              label={__('Remove packages')}
              id="r4-remove-packages"
              ouiaId="r4-remove-packages"
              style={{ marginTop: '0rem' }}
            />
          </div>
        </WizardStep>
        <WizardStep
          name={packageActionsNames[selectedAction]}
          id="mpw-step-2"
          isHidden={selectedAction === UPGRADE_ALL}
          footer={{ isNextDisabled: !step2Valid, onClose: closeModal }}
          status={step2Valid ? 'default' : 'error'}
        >
          {packageActions()}
        </WizardStep>
        <WizardStep
          name={__('Review hosts')}
          id="mpw-step-3"
          status={step3Valid ? 'default' : 'error'}
          footer={{ isNextDisabled: !step4Valid || !packagesResultsPresent, onClose: closeModal }}
        >
          <HostReview
            key={modalOpen}
            selectedAction={selectedAction}
            hostsBulkSelect={hostsBulkSelect}
            initialSelectedHosts={initialSelectedHosts}
            setShouldValidateStep={setShouldValidateStep3}
            warningBanner={getContentWarning()}
          />
        </WizardStep>
        <WizardStep
          name={__('Review')}
          id="mpw-review-step"
          footer={<BulkPackagesReviewFooter />}
          isDisabled={!step4Valid || !packagesResultsPresent}
        >
          <BulkPackagesReview showCVEnvMismatchWarning={CVEnvMismatch} />
        </WizardStep>
      </Wizard>
    </BulkPackagesWizardContext.Provider>
  );
};

export default BulkPackagesWizard;
