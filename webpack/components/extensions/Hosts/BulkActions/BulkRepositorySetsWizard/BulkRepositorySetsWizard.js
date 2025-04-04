import React, { useState, createContext, useContext } from 'react';
import {
  Text,
  TextVariants,
  TextContent,
  Wizard,
  WizardHeader,
  WizardStep,
} from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';
import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';
import { useBulkSelect } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import { useForemanOrganization } from 'foremanReact/Root/Context/ForemanContext';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import { useTableIndexAPIResponse, useSetParamsAndApiAndSearch } from 'foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks';

import { BulkRepositorySetsTable } from './01_BulkRepositorySetsTable';
import { BulkRepositorySetsReview } from './03_Review';
import HostReview from '../HostReview';
import katelloApi from '../../../../../services/api';
import { useHostsBulkSelect } from '../BulkPackagesWizard/BulkPackagesWizard';
import { BulkRepositorySetsReviewFooter } from './03_ReviewFooter';

const DEFAULT_PER_PAGE = 5;
export const BulkRepositorySetsWizardContext = createContext({});
export const repoSetsUrlForOrg = orgId =>
  katelloApi.getApiUrl(`/repository_sets?per_page=${DEFAULT_PER_PAGE}&include_permissions=true&enabled=true&with_custom=true&organization_id=${orgId}`);

const BulkRepositorySetsWizard = () => {
  const { modalOpen, setModalClosed: closeModal } = useForemanModal({ id: 'bulk-repo-sets-wizard' });
  const orgId = useForemanOrganization()?.id;
  const [pendingOverrides, setPendingOverrides] = useState({}); // { repo_label: 1 }
  const [shouldValidateStep2, setShouldValidateStep2] = useState(false);
  const [shouldValidateStep1, setShouldValidateStep1] = useState(false);
  const [, setCurrentStep] = useState();
  const onStepChange = (_event, newStep) => setCurrentStep((oldStep) => {
    setShouldValidateStep1(true);
    if (oldStep === 'brsw-step-2') setShouldValidateStep2(true);
    return newStep?.id;
  });
  const apiOptions = { key: 'BULK_HOST_REPO_SETS' };

  const finishButtonText = __('Set content overrides');
  const replacementResponse = !modalOpen ? { response: {} } : false;
  const { selectedCount: initialSelectedHostCount, fetchBulkParams }
      = useContext(ForemanActionsBarContext);
  const repoSetsResponse = useTableIndexAPIResponse({
    replacementResponse, // don't fetch data if modal is closed
    apiUrl: repoSetsUrlForOrg(orgId),
    apiOptions,
    defaultParams: { per_page: DEFAULT_PER_PAGE },
  });

  const {
    response: {
      results: repoSetsResults,
      ...repoSetsMetadata
    },
    setAPIOptions,
  } = repoSetsResponse;

  const { total, page, subtotal } = repoSetsMetadata;

  const repoSetsBulkSelect = useBulkSelect({
    results: repoSetsResults,
    metadata: { total, page, selectable: subtotal },
    idColumn: 'label',
  });

  const {
    setParamsAndAPI: setRepoSetsParamsAndAPI,
  } = useSetParamsAndApiAndSearch({
    defaultParams: { search: '' },
    apiOptions,
    setAPIOptions,
    updateSearchQuery: repoSetsBulkSelect.updateSearchQuery,
    pushToHistory: false,
  });

  const initialSelectedHosts = fetchBulkParams();

  const hostsBulkSelect =
    useHostsBulkSelect({ initialSelectedHosts, modalIsOpen: modalOpen });

  // eslint-disable-next-line no-restricted-globals
  const selectionIsValid = count => count > 0 || isNaN(count);
  const pendingOverridesCount =
    Object.values(pendingOverrides).filter(val => Number(val) !== 0).length;
  const repoSetsSelectionIsValid =
    selectionIsValid(pendingOverridesCount);
  const hostSelectionIsValid = selectionIsValid(hostsBulkSelect.hostsBulkSelect.selectedCount);
  const step1Valid = shouldValidateStep1 ? repoSetsSelectionIsValid : true;
  const step2Valid = shouldValidateStep2 ? hostSelectionIsValid : true;
  const allStepsValid = step1Valid && step2Valid;
  const [finishButtonLoading, setFinishButtonLoading] = useState(false);

  const BulkRepositorySetsWizardContextData = {
    pendingOverrides,
    setPendingOverrides,
    finishButtonText,
    initialSelectedHostCount,
    shouldValidateStep1,
    setShouldValidateStep1,
    setShouldValidateStep2,
    allStepsValid,
    repoSetsSelectionIsValid,
    setRepoSetsParamsAndAPI,
    finishButtonLoading,
    setFinishButtonLoading,
    closeModal,
    repoSetsBulkSelect,
    repoSetsResults,
    repoSetsMetadata,
    repoSetsResponse,
    hostsBulkSelect: hostsBulkSelect.hostsBulkSelect,
  };
  return (
    <BulkRepositorySetsWizardContext.Provider value={BulkRepositorySetsWizardContextData}>
      <Wizard
        header={<WizardHeader title={__('Manage repository sets')} onClose={closeModal} />}
        onStepChange={onStepChange}
      >
        <WizardStep
          name={__('Select repository sets')}
          id="brsw-step-1"
          footer={{ isNextDisabled: !step1Valid, onClose: closeModal }}
          status={step1Valid ? 'default' : 'error'}
        >
          <TextContent>
            <Text component={TextVariants.h3} ouiaId="bulk-repo-sets-wizard-header">
              {__('Select repository sets')}
            </Text>
            <Text component={TextVariants.p} ouiaId="bulk-repo-sets-wizard-description">
              {__('Below you can add content overrides, which change whether a repository is enabled or disabled. Change their state one by one, or use the checkboxes and select an action to perform.')}
            </Text>
          </TextContent>
          <BulkRepositorySetsTable
            repoSetsBulkSelect={repoSetsBulkSelect}
            repoSetsResults={repoSetsResults}
            repoSetsMetadata={repoSetsMetadata}
            repoSetsResponse={repoSetsResponse}
          />
        </WizardStep>
        <WizardStep
          name={__('Review hosts')}
          id="brsw-step-2"
          footer={{ isNextDisabled: !step2Valid, onClose: closeModal }}
          status={step2Valid ? 'default' : 'error'}
        >
          <HostReview
            key={modalOpen}
            hostsBulkSelect={hostsBulkSelect}
            initialSelectedHosts={initialSelectedHosts}
            setShouldValidateStep={setShouldValidateStep2}
          />
        </WizardStep>
        <WizardStep
          name={__('Review')}
          id="brsw-step-3"
          footer={<BulkRepositorySetsReviewFooter />}
        >
          <BulkRepositorySetsReview />
        </WizardStep>
      </Wizard>
    </BulkRepositorySetsWizardContext.Provider>
  );
};

export default BulkRepositorySetsWizard;
