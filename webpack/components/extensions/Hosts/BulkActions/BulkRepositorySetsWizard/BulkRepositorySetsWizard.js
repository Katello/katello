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
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import { useTableIndexAPIResponse } from 'foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks';

import { BulkRepositorySetsTable } from './01_BulkRepositorySetsTable';
// import { STATUS } from 'foremanReact/constants';
// import HostReview from '../HostReview';
// import { BulkRepositorySetsReview, dropdownOptions } from './04_Review';
// import { BulkRepositorySetsReviewFooter } from './04_ReviewFooter';
import katelloApi from '../../../../../services/api';
import { useHostsBulkSelect } from '../BulkPackagesWizard/BulkPackagesWizard';

export const BulkRepositorySetsWizardContext = createContext({});
export const REPO_SETS_URL = katelloApi.getApiUrl('/repository_sets?per_page=7&include_permissions=true&enabled=true&with_custom=true&organization_id=1');

const BulkRepositorySetsWizard = () => {
  const { modalOpen, setModalClosed: closeModal } = useForemanModal({ id: 'bulk-repo-sets-wizard' });
  const [pendingOverrides, setPendingOverrides] = useState({}); // { repo_label: 1 }
  const apiOptions = { key: 'BULK_HOST_REPO_SETS' };

  const finishButtonText = 'Set content overrides';
  const replacementResponse = !modalOpen ? { response: {} } : false;
  const { selectedCount: initialSelectedHostCount, fetchBulkParams }
      = useContext(ForemanActionsBarContext);
  const repoSetsResponse = useTableIndexAPIResponse({
    replacementResponse, // don't fetch data if modal is closed
    apiUrl: REPO_SETS_URL,
    apiOptions,
  });

  const {
    response: {
      results: repoSetsResults,
      ...repoSetsMetadata
    },
    // status: repoSetsStatus,
  } = repoSetsResponse;

  const { total, page, subtotal } = repoSetsMetadata;

  const repoSetsBulkSelect = useBulkSelect({
    results: repoSetsResults,
    metadata: { total, page, selectable: subtotal },
    idColumn: 'label',
  });

  const initialSelectedHosts = fetchBulkParams();

  const hostsBulkSelect =
    useHostsBulkSelect({ initialSelectedHosts, modalIsOpen: modalOpen });

  // eslint-disable-next-line no-restricted-globals
  // const selectionIsValid = count => count > 0 || isNaN(count);
  // const repoSetsResultsPresent = (repoSetsResults?.length ?? 0) > 0;
  // const repoSetsSelectionIsValid =
  //   selectionIsValid(repoSetsBulkSelect.selectedCount);
  // const hostSelectionIsValid = selectionIsValid(hostsBulkSelect.hostsBulkSelect.selectedCount);
  // let step2Valid = shouldValidateStep2 ? packageSelectionIsValid : true;
  // if (!repoSetsResultsPresent) step2Valid = false;
  // const step3Valid = shouldValidateStep3 ? hostSelectionIsValid : true;
  // const step4Valid = hostSelectionIsValid && packageSelectionIsValid;

  const BulkRepositorySetsWizardContextData = {
    pendingOverrides,
    setPendingOverrides,
    finishButtonText,
    initialSelectedHostCount,
    // setShouldValidateStep2,
    // finishButtonLoading,
    // setFinishButtonLoading,
    // selectedRexOption,
    // setSelectedRexOption,
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
      >
        <WizardStep
          name={__('Select repository sets')}
          id="brsw-step-1"
          footer={{ onClose: closeModal }}
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
      </Wizard>
    </BulkRepositorySetsWizardContext.Provider>
  );
};

export default BulkRepositorySetsWizard;
