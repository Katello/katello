import React, { useContext, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { ExpandableSection, SelectOption } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import getContentViews from '../../ContentViewsActions';
import { selectContentViewError, selectContentViews, selectContentViewStatus } from '../../ContentViewSelectors';
import CVDeleteContext from '../CVDeleteContext';
import EnvironmentPaths from '../../components/EnvironmentPaths/EnvironmentPaths';
import AffectedActivationKeys from '../../Details/Versions/Delete/affectedActivationKeys';
import ContentViewSelect from '../../components/ContentViewSelect/ContentViewSelect';

const CVDeletionReassignActivationKeysForm = () => {
  const dispatch = useDispatch();
  const contentViewsInEnvResponse = useSelector(state => selectContentViews(state, 'keys'));
  const contentViewsInEnvStatus = useSelector(state => selectContentViewStatus(state, 'keys'));
  const contentViewsInEnvError = useSelector(state => selectContentViewError(state, 'keys'));
  const cvInEnvLoading = contentViewsInEnvStatus === STATUS.PENDING;
  const [cvSelectOpen, setCVSelectOpen] = useState(false);
  const [cvSelectOptions, setCvSelectionOptions] = useState([]);
  const [showActivationKeys, setShowActivationKeys] = useState(false);
  const {
    currentStep, selectedEnvForAK, cvEnvironments, cvId,
    setSelectedEnvForAK, selectedCVForAK, setSelectedCVNameForAK, setSelectedCVForAK,
  } = useContext(CVDeleteContext);

  useDeepCompareEffect(
    () => {
      if (selectedEnvForAK.length) {
        dispatch(getContentViews({
          environment_id: selectedEnvForAK[0].id,
          include_default: true,
          full_result: true,
        }, 'keys'));
      }
      setCVSelectOpen(false);
    },
    [selectedEnvForAK, dispatch, setCVSelectOpen],
  );

  useDeepCompareEffect(() => {
    const { results = [] } = contentViewsInEnvResponse;
    const contentViewEligible = cv => Number(cv.id) !== Number(cvId);
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
    cvInEnvLoading, selectedCVForAK, cvId]);

  const fetchSelectedCVName = (id) => {
    const { results } = contentViewsInEnvResponse ?? { };
    return results?.filter(cv => cv.id === id)[0]?.name;
  };

  const onClear = () => {
    setSelectedCVForAK(null);
    setSelectedCVNameForAK(null);
  };

  const onSelect = (_event, selection) => {
    setSelectedCVForAK(selection);
    setSelectedCVNameForAK(fetchSelectedCVName(selection));
    setCVSelectOpen(false);
  };

  return (
    <>
      <EnvironmentPaths
        userCheckedItems={selectedEnvForAK}
        setUserCheckedItems={setSelectedEnvForAK}
        publishing={false}
        headerText={__('Select lifecycle environment')}
        multiSelect={false}
      />
      {!cvInEnvLoading && selectedEnvForAK.length > 0 &&
        <ContentViewSelect
          selections={selectedCVForAK}
          onSelect={onSelect}
          onClear={onClear}
          isOpen={cvSelectOpen}
          isDisabled={cvSelectOptions.length === 0}
          onToggle={isExpanded => setCVSelectOpen(isExpanded)}
          placeholderText={(cvSelectOptions.length === 0) ? __('No content views available') : __('Select a content view')}
        >
          {cvSelectOptions}
        </ContentViewSelect>
      }
      <ExpandableSection
        toggleText={showActivationKeys ?
          'Hide activation keys' :
          'Show activation keys'}
        onToggle={expanded => setShowActivationKeys(expanded)}
        isExpanded={showActivationKeys}
      >
        <AffectedActivationKeys
          {...{
            cvId,
          }}
          versionEnvironments={cvEnvironments}
          deleteCV
        />
      </ExpandableSection>
    </>
  );
};

export default CVDeletionReassignActivationKeysForm;
