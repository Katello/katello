import React, { useState, useContext } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { ExpandableSection, Select, SelectOption } from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import EnvironmentPaths from '../../../../components/EnvironmentPaths/EnvironmentPaths';
import getContentViews from '../../../../ContentViewsActions';
import { selectContentViewError, selectContentViews, selectContentViewStatus } from '../../../../ContentViewSelectors';
import AffectedActivationKeys from '../affectedActivationKeys';
import DeleteContext from '../DeleteContext';

const CVReassignActivationKeysForm = () => {
  const dispatch = useDispatch();
  const contentViewsInEnvResponse = useSelector(selectContentViews);
  const contentViewsInEnvStatus = useSelector(selectContentViewStatus);
  const contentViewsInEnvError = useSelector(selectContentViewError);
  const cvInEnvLoading = contentViewsInEnvStatus === STATUS.PENDING;
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

  const fetchSelectedCVName = (id) => {
    const { results } = contentViewsInEnvResponse ?? { };
    return results.filter(cv => cv.id === id)[0]?.name;
  };

  const onSelect = (event, selection) => {
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
        <div style={{ marginTop: '1em' }}>
          <h3>{__('Select content view')}</h3>
          <Select
            selections={selectedCVForAK}
            onSelect={onSelect}
            isOpen={cvSelectOpen}
            isDisabled={cvSelectOptions.length === 0}
            onToggle={isExpanded => setCVSelectOpen(isExpanded)}
            id="selectCV"
            name="selectCV"
            aria-label="selectCV"
            placeholderText={(cvSelectOptions.length === 0) ? __('No content views available') : __('Select a content view')}
          >
            {cvSelectOptions}
          </Select>
        </div>
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
