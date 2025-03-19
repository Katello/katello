import React, { useState, useContext } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import useDeepCompareEffect from 'use-deep-compare-effect';
import {
  ExpandableSection,
} from '@patternfly/react-core';
import {
  SelectOption,
} from '@patternfly/react-core/deprecated';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import getContentViews from '../../ContentViewsActions';
import { selectContentViewError, selectContentViews, selectContentViewStatus } from '../../ContentViewSelectors';
import CVDeleteContext from '../CVDeleteContext';
import EnvironmentPaths from '../../components/EnvironmentPaths/EnvironmentPaths';
import AffectedHosts from '../../Details/Versions/Delete/affectedHosts';
import ContentViewSelect from '../../components/ContentViewSelect/ContentViewSelect';
import { getCVPlaceholderText, shouldDisableCVSelect } from '../../components/ContentViewSelect/helpers';


const CVDeletionReassignHostsForm = () => {
  const dispatch = useDispatch();
  const contentViewsInEnvResponse = useSelector(state => selectContentViews(state, 'host'));
  const contentViewsInEnvStatus = useSelector(state => selectContentViewStatus(state, 'host'));
  const contentViewsInEnvError = useSelector(state => selectContentViewError(state, 'host'));
  const cvInEnvLoading = contentViewsInEnvStatus === STATUS.PENDING;
  const [cvSelectOpen, setCVSelectOpen] = useState(false);
  const [cvSelectOptions, setCvSelectionOptions] = useState([]);
  const [showHosts, setShowHosts] = useState(false);
  const {
    cvId, cvEnvironments, selectedEnvSet, selectedEnvForHost, setSelectedEnvForHost,
    currentStep, selectedCVForHosts, setSelectedCVNameForHosts, setSelectedCVForHosts,
  } = useContext(CVDeleteContext);

  useDeepCompareEffect(
    () => {
      if (selectedEnvForHost.length) {
        dispatch(getContentViews({
          environment_id: selectedEnvForHost[0].id,
          include_default: true,
          full_result: true,
        }, 'host'));
      }
      setCVSelectOpen(false);
    },
    [selectedEnvForHost, dispatch, setCVSelectOpen],
  );

  useDeepCompareEffect(() => {
    const { results = [] } = contentViewsInEnvResponse;
    const contentViewEligible = cv => Number(cv.id) !== Number(cvId);
    if (!cvInEnvLoading && results && selectedCVForHosts &&
      results.filter(cv => cv.id === selectedCVForHosts && contentViewEligible(cv)).length === 0) {
      setSelectedCVForHosts(null);
      setSelectedCVNameForHosts(null);
    }
    if (!cvInEnvLoading && results && selectedEnvForHost.length) {
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
  }, [contentViewsInEnvResponse, contentViewsInEnvStatus, currentStep,
    contentViewsInEnvError, selectedEnvForHost, setSelectedCVForHosts, setSelectedCVNameForHosts,
    cvInEnvLoading, selectedCVForHosts, cvId, cvEnvironments, selectedEnvSet]);

  const fetchSelectedCVName = (id) => {
    const { results } = contentViewsInEnvResponse ?? { };
    return results?.filter(cv => cv.id === id)[0]?.name;
  };

  const onClear = () => {
    setSelectedCVForHosts(null);
    setSelectedCVNameForHosts(null);
  };

  const onSelect = (_event, selection) => {
    setSelectedCVForHosts(selection);
    setSelectedCVNameForHosts(fetchSelectedCVName(selection));
    setCVSelectOpen(false);
  };

  const placeholderText = getCVPlaceholderText({
    contentSourceId: null,
    environments: selectedEnvForHost,
    contentViewsStatus: contentViewsInEnvStatus,
    cvSelectOptions,
  });

  const disableCVSelect = shouldDisableCVSelect({
    contentSourceId: null,
    environments: selectedEnvForHost,
    contentViewsStatus: contentViewsInEnvStatus,
    cvSelectOptions,
  });


  return (
    <>
      <EnvironmentPaths
        userCheckedItems={selectedEnvForHost}
        setUserCheckedItems={setSelectedEnvForHost}
        publishing={false}
        headerText={__('Select lifecycle environment')}
        multiSelect={false}
      />
      <ContentViewSelect
        selections={selectedCVForHosts}
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
        toggleText={showHosts ? 'Hide hosts' : 'Show hosts'}
        onToggle={(_event, expanded) => setShowHosts(expanded)}
        isExpanded={showHosts}
      >
        <AffectedHosts
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

export default CVDeletionReassignHostsForm;
