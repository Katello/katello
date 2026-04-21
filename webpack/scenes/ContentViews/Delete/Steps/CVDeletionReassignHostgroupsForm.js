import React, { useState, useContext } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { ExpandableSection } from '@patternfly/react-core';
import { SelectOption } from '@patternfly/react-core/deprecated';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import getContentViews from '../../ContentViewsActions';
import { selectContentViewError, selectContentViews, selectContentViewStatus } from '../../ContentViewSelectors';
import CVDeleteContext from '../CVDeleteContext';
import EnvironmentPaths from '../../components/EnvironmentPaths/EnvironmentPaths';
import ContentViewSelect from '../../components/ContentViewSelect/ContentViewSelect';
import { getCVPlaceholderText, shouldDisableCVSelect } from '../../components/ContentViewSelect/helpers';
import AffectedHostgroups from '../../Details/Versions/Delete/affectedHostgroups';


const CVDeletionReassignHostgroupsForm = () => {
  const dispatch = useDispatch();
  const contentViewsInEnvResponse = useSelector(state => selectContentViews(state, 'hostgroup'));
  const contentViewsInEnvStatus = useSelector(state => selectContentViewStatus(state, 'hostgroup'));
  const contentViewsInEnvError = useSelector(state => selectContentViewError(state, 'hostgroup'));
  const cvInEnvLoading = contentViewsInEnvStatus === STATUS.PENDING;
  const [cvSelectOpen, setCVSelectOpen] = useState(false);
  const [cvSelectOptions, setCvSelectionOptions] = useState([]);
  const [showHostgroups, setShowHostgroups] = useState(false);
  const {
    cvId, cvEnvironments, selectedEnvSet, selectedEnvForHostgroup,
    setSelectedEnvForHostgroup, currentStep, selectedCVForHostgroups,
    setSelectedCVNameForHostgroups, setSelectedCVForHostgroups,
  } = useContext(CVDeleteContext);

  useDeepCompareEffect(
    () => {
      if (selectedEnvForHostgroup.length) {
        dispatch(getContentViews({
          environment_id: selectedEnvForHostgroup[0].id,
          include_default: true,
          full_result: true,
        }, 'hostgroup'));
      }
      setCVSelectOpen(false);
    },
    [selectedEnvForHostgroup, dispatch, setCVSelectOpen],
  );

  useDeepCompareEffect(() => {
    const { results = [] } = contentViewsInEnvResponse;
    const contentViewEligible = cv => Number(cv.id) !== Number(cvId);
    const isSelectedCVInvalid = !cvInEnvLoading && results && selectedCVForHostgroups &&
      results.filter(cv => cv.id === selectedCVForHostgroups &&
        contentViewEligible(cv)).length === 0;
    if (isSelectedCVInvalid) {
      setSelectedCVForHostgroups(null);
      setSelectedCVNameForHostgroups(null);
    }
    if (!cvInEnvLoading && results && selectedEnvForHostgroup.length) {
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
    contentViewsInEnvError, selectedEnvForHostgroup, setSelectedCVForHostgroups,
    setSelectedCVNameForHostgroups, cvInEnvLoading, selectedCVForHostgroups,
    cvId, cvEnvironments, selectedEnvSet]);

  const fetchSelectedCVName = (id) => {
    const { results } = contentViewsInEnvResponse ?? { };
    return results?.filter(cv => cv.id === id)[0]?.name;
  };

  const onClear = () => {
    setSelectedCVForHostgroups(null);
    setSelectedCVNameForHostgroups(null);
  };

  const onSelect = (_event, selection) => {
    setSelectedCVForHostgroups(selection);
    setSelectedCVNameForHostgroups(fetchSelectedCVName(selection));
    setCVSelectOpen(false);
  };

  const placeholderText = getCVPlaceholderText({
    contentSourceId: null,
    environments: selectedEnvForHostgroup,
    contentViewsStatus: contentViewsInEnvStatus,
    cvSelectOptions,
  });

  const disableCVSelect = shouldDisableCVSelect({
    contentSourceId: null,
    environments: selectedEnvForHostgroup,
    contentViewsStatus: contentViewsInEnvStatus,
    cvSelectOptions,
  });

  return (
    <>
      <EnvironmentPaths
        userCheckedItems={selectedEnvForHostgroup}
        setUserCheckedItems={setSelectedEnvForHostgroup}
        publishing={false}
        headerText={__('Select lifecycle environment')}
        multiSelect={false}
      />
      <ContentViewSelect
        selections={selectedCVForHostgroups}
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
        toggleText={showHostgroups ? __('Hide host groups') : __('Show host groups')}
        onToggle={(_event, expanded) => setShowHostgroups(expanded)}
        isExpanded={showHostgroups}
      >
        <AffectedHostgroups cvId={cvId} selectedEnvSet={selectedEnvSet} />
      </ExpandableSection>
    </>
  );
};

export default CVDeletionReassignHostgroupsForm;
