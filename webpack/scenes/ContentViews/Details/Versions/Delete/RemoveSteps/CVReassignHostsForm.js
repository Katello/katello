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
  const contentViewsInEnvResponse = useSelector(selectContentViews);
  const contentViewsInEnvStatus = useSelector(selectContentViewStatus);
  const contentViewsInEnvError = useSelector(selectContentViewError);
  const cvInEnvLoading = contentViewsInEnvStatus === STATUS.PENDING;
  const [cvSelectOpen, setCVSelectOpen] = useState(false);
  const [cvSelectOptions, setCvSelectionOptions] = useState([]);
  const [showHosts, setShowHosts] = useState(false);
  const {
    cvId, versionEnvironments, selected, selectedEnvForHost, setSelectedEnvForHost,
    currentStep, selectedCVForHosts, setSelectedCVNameForHosts, setSelectedCVForHosts,
  } = useContext(DeleteContext);

  useDeepCompareEffect(
    () => {
      if (selectedEnvForHost.length) {
        dispatch(getContentViews({
          environment_id: selectedEnvForHost[0].id,
          include_default: true,
          full_result: true,
        }));
      }
      setCVSelectOpen(false);
    },
    [selectedEnvForHost, dispatch, setCVSelectOpen],
  );

  useDeepCompareEffect(() => {
    const { results = {} } = contentViewsInEnvResponse;
    const contentViewElligible = (cv) => {
      if (cv.id === cvId) {
        const selectedEnv = versionEnvironments.filter((_env, index) => selected[index]);
        return (selectedEnv.filter(env => env.id === selectedEnvForHost[0]?.id).length === 0);
      }
      return true;
    };
    if (!cvInEnvLoading && results && selectedCVForHosts &&
      results.filter(cv => cv.id === selectedCVForHosts && contentViewElligible(cv)).length === 0) {
      setSelectedCVForHosts(null);
      setSelectedCVNameForHosts(null);
    }
    if (!cvInEnvLoading && results && selectedEnvForHost.length) {
      setCvSelectionOptions(results.map(cv => ((contentViewElligible(cv)) ?
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
    cvInEnvLoading, selectedCVForHosts, cvId, versionEnvironments, selected]);

  const fetchSelectedCVName = (id) => {
    const { results } = contentViewsInEnvResponse || { };
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
          onToggle={isExpanded => setCVSelectOpen(isExpanded)}
          id="selectCV"
          name="selectCV"
          aria-label="selectCV"
          placeholderText={__('Select a content view')}
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
        <AffectedHosts />
      </ExpandableSection>
    </>
  );
};

export default CVReassignHostsForm;
