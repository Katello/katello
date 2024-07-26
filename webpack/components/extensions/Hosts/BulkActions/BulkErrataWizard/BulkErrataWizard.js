import React, { useState, createContext, useContext } from 'react';
import { Wizard, WizardHeader, WizardStep } from '@patternfly/react-core/next';
import { translate as __ } from 'foremanReact/common/I18n';
import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';
import { useBulkSelect } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import { useTableIndexAPIResponse } from 'foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks';
import { STATUS } from 'foremanReact/constants';
import { HOSTS_API_PATH } from 'foremanReact/routes/Hosts/constants';
import HostReview from '../HostReview';
import { BulkErrataReview, dropdownOptions } from './04_Review';
import BulkErrataTable from './02_BulkErrataTable';
import { BulkErrataReviewFooter } from './04_ReviewFooter';
import katelloApi from '../../../../../services/api';

export const BulkErrataWizardContext = createContext({});

export const useErrataHostsBulkSelect = ({ initialSelectedHosts, modalIsOpen }) => {
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

export const ERRATA_URL = `${katelloApi.getApiUrl('/errata')}?per_page=7&include_permissions=true`;

const BulkErrataWizard = () => {
  const { modalOpen, setModalClosed: closeModal } = useForemanModal({ id: 'bulk-errata-wizard' });
  const { selectedCount: initialSelectedHostCount, fetchBulkParams }
    = useContext(ForemanActionsBarContext);

  const [shouldValidateStep2, setShouldValidateStep2] = useState(false);
  const [shouldValidateStep3, setShouldValidateStep3] = useState(false);
  const [finishButtonLoading, setFinishButtonLoading] = useState(false);
  const [selectedRexOption, setSelectedRexOption] = useState(dropdownOptions[0]);
  const finishButtonText = __('Apply');
  const replacementResponse = !modalOpen ? { response: {} } : false;
  const initialSelectedHosts = fetchBulkParams();
  const apiOptions = { key: 'BULK_HOST_ERRATA' };
  const defaultParams = { included: { search: initialSelectedHosts } };
  const hostsBulkSelect =
    useErrataHostsBulkSelect({ initialSelectedHosts, modalIsOpen: modalOpen });

  const errataResponse = useTableIndexAPIResponse({
    replacementResponse, // don't fetch data if modal is closed
    apiUrl: ERRATA_URL,
    apiOptions,
    defaultParams,
  });

  const {
    status: errataStatus,
    response: {
      results: errataResults,
      ...errataMetadata
    },
  } = errataResponse;

  const { total, page, subtotal } = errataMetadata;

  const errataBulkSelect = useBulkSelect({
    results: errataResults,
    metadata: { total, page, selectable: subtotal },
    idColumn: 'errata_id',
  });

  // eslint-disable-next-line no-restricted-globals
  const selectionIsValid = count => count > 0 || isNaN(count);
  const errataResultsPresent = errataResults?.length > 0;
  const errataSelectionIsValid =
    selectionIsValid(errataBulkSelect.selectedCount);
  const hostSelectionIsValid = selectionIsValid(hostsBulkSelect.hostsBulkSelect.selectedCount);
  let step2Valid = shouldValidateStep2 ? errataSelectionIsValid : true;
  if (errataStatus === STATUS.RESOLVED && !errataResultsPresent) step2Valid = false;
  const step3Valid = shouldValidateStep3 ? hostSelectionIsValid : true;
  const step4Valid = hostSelectionIsValid && errataSelectionIsValid;

  const BulkErrataWizardContextData = {
    finishButtonText,
    initialSelectedHostCount,
    setShouldValidateStep2,
    finishButtonLoading,
    setFinishButtonLoading,
    selectedRexOption,
    setSelectedRexOption,
    closeModal,
    errataBulkSelect,
    errataResults,
    errataMetadata,
    errataResponse,
    hostsBulkSelect: hostsBulkSelect.hostsBulkSelect,
  };
  return (
    <BulkErrataWizardContext.Provider value={BulkErrataWizardContextData}>
      <Wizard
        header={<WizardHeader title={__('Manage errata')} onClose={closeModal} />}
      >
        <WizardStep
          name={__('Select errata')}
          id="mew-step-2"
          footer={{ isNextDisabled: !step2Valid, onClose: closeModal }}
          status={step2Valid ? 'default' : 'error'}
        >
          <BulkErrataTable modalIsOpen={modalOpen} />
        </WizardStep>
        <WizardStep
          name={__('Review hosts')}
          id="mew-step-3"
          status={step3Valid ? 'default' : 'error'}
          footer={{ isNextDisabled: !step4Valid || !errataResultsPresent, onClose: closeModal }}
        >
          <HostReview
            key={modalOpen}
            hostsBulkSelect={hostsBulkSelect}
            initialSelectedHosts={initialSelectedHosts}
            setShouldValidateStep={setShouldValidateStep3}
          />
        </WizardStep>
        <WizardStep
          name={__('Review')}
          id="mew-review-step"
          footer={<BulkErrataReviewFooter />}
          isDisabled={!step4Valid || !errataResultsPresent}
        >
          <BulkErrataReview />
        </WizardStep>
      </Wizard>
    </BulkErrataWizardContext.Provider>
  );
};

export default BulkErrataWizard;
