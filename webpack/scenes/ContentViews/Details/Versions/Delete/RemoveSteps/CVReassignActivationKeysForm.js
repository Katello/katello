import React, { useState, useContext } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import useDeepCompareEffect from 'use-deep-compare-effect';
import {
  ExpandableSection, Alert, AlertActionCloseButton,
} from '@patternfly/react-core';
import {
  SelectOption,
} from '@patternfly/react-core/deprecated';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import EnvironmentPaths from '../../../../components/EnvironmentPaths/EnvironmentPaths';
import getContentViews from '../../../../ContentViewsActions';
import { selectContentViewError, selectContentViews, selectContentViewStatus } from '../../../../ContentViewSelectors';
import { selectCVActivationKeys } from '../../../ContentViewDetailSelectors';
import AffectedActivationKeys from '../affectedActivationKeys';
import DeleteContext from '../DeleteContext';
import ContentViewSelect from '../../../../components/ContentViewSelect/ContentViewSelect';
import { getCVPlaceholderText, shouldDisableCVSelect } from '../../../../components/ContentViewSelect/helpers';

const CVReassignActivationKeysForm = () => {
  const dispatch = useDispatch();
  const contentViewsInEnvResponse = useSelector(selectContentViews);
  const contentViewsInEnvStatus = useSelector(selectContentViewStatus);
  const contentViewsInEnvError = useSelector(selectContentViewError);
  const activationKeysResponse = useSelector(selectCVActivationKeys);
  const cvInEnvLoading = contentViewsInEnvStatus === STATUS.PENDING;
  const [alertDismissed, setAlertDismissed] = useState(false);
  const [cvSelectOpen, setCVSelectOpen] = useState(false);
  const [cvSelectOptions, setCvSelectionOptions] = useState([]);
  const [showActivationKeys, setShowActivationKeys] = useState(false);
  const {
    currentStep, selectedEnvForAK, versionEnvironments, cvId, selectedEnvSet,
    setSelectedEnvForAK, selectedCVForAK, setSelectedCVNameForAK, setSelectedCVForAK,
  } = useContext(DeleteContext);

  // Fetch content views for selected environment to reassign activation keys to.
  useDeepCompareEffect(
    () => {
      if (selectedEnvForAK.length) {
        dispatch(getContentViews({
          environment_id: selectedEnvForAK[0].id,
          include_default: true,
          full_result: true,
        }));
      }
      setCVSelectOpen(false);
    },
    [selectedEnvForAK, dispatch, setCVSelectOpen],
  );

  // Upon receiving CVs in selected env, form select options for the content view drop down
  useDeepCompareEffect(() => {
    const { results } = contentViewsInEnvResponse;
    // Filter out the cv in the environments that are currently being removed
    const contentViewEligible = (cv) => {
      if (cv.id === cvId) {
        const selectedEnv = versionEnvironments.filter(env => selectedEnvSet.has(env.id));
        return (selectedEnv.filter(env => env.id === selectedEnvForAK[0]?.id).length === 0);
      }
      return true;
    };
    if (!cvInEnvLoading && results && selectedEnvForAK.length) {
      setCvSelectionOptions(results.map(cv => ((contentViewEligible(cv)) ?
        (
          <SelectOption
            key={cv.id}
            value={cv.id}
          >
            {cv.name}
          </SelectOption>
        ) : null)).filter(n => n));
    }
    if (!cvInEnvLoading && results && selectedCVForAK &&
      results.filter(cv => cv.id === selectedCVForAK && contentViewEligible(cv)).length === 0) {
      setSelectedCVForAK(null);
      setSelectedCVNameForAK(null);
    }
  }, [contentViewsInEnvResponse, contentViewsInEnvStatus, currentStep,
    contentViewsInEnvError, selectedEnvForAK, setSelectedCVForAK, setSelectedCVNameForAK,
    cvInEnvLoading, selectedCVForAK, cvId, versionEnvironments, selectedEnvSet]);

  const multiCVWarning = activationKeysResponse?.results?.some?.(key =>
    key.multi_content_view_environment);

  const fetchSelectedCVName = (id) => {
    const { results } = contentViewsInEnvResponse ?? { };
    return results.filter(cv => cv.id === id)[0]?.name;
  };

  const onClear = () => {
    setSelectedCVForAK(null);
    setSelectedCVNameForAK(null);
  };

  const onSelect = (event, selection) => {
    setSelectedCVForAK(selection);
    setSelectedCVNameForAK(fetchSelectedCVName(selection));
    setCVSelectOpen(false);
  };

  const placeholderText = getCVPlaceholderText({
    contentSourceId: null,
    environments: selectedEnvForAK,
    contentViewsStatus: contentViewsInEnvStatus,
    cvSelectOptions,
  });

  const disableCVSelect = shouldDisableCVSelect({
    contentSourceId: null,
    environments: selectedEnvForAK,
    contentViewsStatus: contentViewsInEnvStatus,
    cvSelectOptions,
  });

  const multiCVRemovalInfo = __('This environment is used in one or more multi-environment activation keys. The environment will simply be removed from the multi-environment keys. The content view and lifecycle environment you select here will only apply to single-environment activation keys. See hammer activation-key --help for more details.');

  return (
    <>
      {!alertDismissed && multiCVWarning && (
        <Alert
          ouiaId="multi-cv-warning-alert"
          variant="warning"
          isInline
          title={__('Warning')}
          actionClose={<AlertActionCloseButton onClose={() => setAlertDismissed(true)} />}
        >
          <p>{multiCVRemovalInfo}</p>
        </Alert>
      )}
      <EnvironmentPaths
        userCheckedItems={selectedEnvForAK}
        setUserCheckedItems={setSelectedEnvForAK}
        publishing={false}
        headerText={__('Select lifecycle environment')}
        multiSelect={false}
      />
      <ContentViewSelect
        selections={selectedCVForAK}
        onSelect={onSelect}
        onClear={onClear}
        isOpen={cvSelectOpen}
        isDisabled={disableCVSelect}
        onToggle={isExpanded => setCVSelectOpen(isExpanded)}
        placeholderText={placeholderText}
      >
        {cvSelectOptions}
      </ContentViewSelect>
      <ExpandableSection
        toggleText={showActivationKeys ?
          'Hide activation keys' :
          'Show activation keys'}
        onToggle={(_event, expanded) => setShowActivationKeys(expanded)}
        isExpanded={showActivationKeys}
      >
        <AffectedActivationKeys
          {...{
            cvId,
            versionEnvironments,
            selectedEnvSet,
          }}
          deleteCV={false}
        />
      </ExpandableSection>
    </>
  );
};

export default CVReassignActivationKeysForm;
