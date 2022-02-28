import React, { useState, useContext } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { ExpandableSection, Select, SelectOption } from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import EnvironmentPaths from '../../../../components/EnvironmentPaths/EnvironmentPaths';
import getContentViews from '../../../../ContentViewsActions';
import { selectContentViewError, selectContentViews, selectContentViewStatus } from '../../../../ContentViewSelectors';
import AffectedHosts from '../affectedHosts';
import DeleteContext from '../DeleteContext';

const CVReassignHostsForm = () => {
  const dispatch = useDispatch();
  const contentViewsInEnvResponse = useSelector(state => selectContentViews(state, 'host'));
  const contentViewsInEnvStatus = useSelector(state => selectContentViewStatus(state, 'host'));
  const contentViewsInEnvError = useSelector(state => selectContentViewError(state, 'host'));
  const cvInEnvLoading = contentViewsInEnvStatus === STATUS.PENDING;
  const [cvSelectOpen, setCVSelectOpen] = useState(false);
  const [cvSelectOptions, setCvSelectionOptions] = useState([]);
  const [showHosts, setShowHosts] = useState(false);
  const {
    cvId, versionEnvironments, selectedEnvSet, selectedEnvForHost, setSelectedEnvForHost,
    currentStep, selectedCVForHosts, setSelectedCVNameForHosts, setSelectedCVForHosts,
  } = useContext(DeleteContext);

  // Fetch content views for selected environment to reassign hosts to.
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

  // Upon receiving CVs in selected env, form select options for the content view drop down
  useDeepCompareEffect(() => {
    const { results = {} } = contentViewsInEnvResponse;
    const contentViewEligible = (cv) => {
      if (cv.id === cvId) {
        const selectedEnv = versionEnvironments.filter(env => selectedEnvSet.has(env.id));
        return (selectedEnv.filter(env => env.id === selectedEnvForHost[0]?.id).length === 0);
      }
      return true;
    };
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
    cvInEnvLoading, selectedCVForHosts, cvId, versionEnvironments, selectedEnvSet]);

  const fetchSelectedCVName = (id) => {
    const { results } = contentViewsInEnvResponse ?? { };
    return results.filter(cv => cv.id === id)[0]?.name;
  };

  const onSelect = (event, selection) => {
    setSelectedCVForHosts(selection);
    setSelectedCVNameForHosts(fetchSelectedCVName(selection));
    setCVSelectOpen(false);
  };

  return (
    <>
      <EnvironmentPaths
        userCheckedItems={selectedEnvForHost}
        setUserCheckedItems={setSelectedEnvForHost}
        publishing={false}
        headerText={__('Select lifecycle environment')}
        multiSelect={false}
      />
      {selectedEnvForHost.length > 0 &&
      <div style={{ marginTop: '1em' }}>
        <h3>{__('Select content view')}</h3>
        <Select
          selections={selectedCVForHosts}
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
        toggleText={showHosts ? 'Hide hosts' : 'Show hosts'}
        onToggle={expanded => setShowHosts(expanded)}
        isExpanded={showHosts}
      >
        <AffectedHosts
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

export default CVReassignHostsForm;
