import React, { useState, useContext } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { ExpandableSection, Alert, AlertActionCloseButton } from '@patternfly/react-core';
import { SelectOption } from '@patternfly/react-core/deprecated';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import { FormattedMessage } from 'react-intl';
import EnvironmentPaths from '../../../../components/EnvironmentPaths/EnvironmentPaths';
import getContentViews from '../../../../ContentViewsActions';
import { selectContentViewError, selectContentViews, selectContentViewStatus } from '../../../../ContentViewSelectors';
import { selectCVHosts } from '../../../ContentViewDetailSelectors';
import AffectedHosts from '../affectedHosts';
import DeleteContext from '../DeleteContext';
import ContentViewSelect from '../../../../components/ContentViewSelect/ContentViewSelect';
import { getCVPlaceholderText, shouldDisableCVSelect } from '../../../../components/ContentViewSelect/helpers';
import { selectEnvironmentPaths } from '../../../../components/EnvironmentPaths/EnvironmentPathSelectors';

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
  const [alertDismissed, setAlertDismissed] = useState(false);
  const hostResponse = useSelector(selectCVHosts);
  const environmentPathResponse = useSelector(state => selectEnvironmentPaths(state));

  const contentSourceIds = new Set((hostResponse?.results || [])
    .map(host => host.content_facet_attributes?.content_source_id)
    .filter(id => id));

  const lifecycleEnvironments = environmentPathResponse?.results?.map(path =>
    path.environments).flat() || [];

  const enabledLifecycleEnvironmentIds = new Set();

  if (lifecycleEnvironments) {
    lifecycleEnvironments.forEach((env) => {
      if (env.capsules) {
        env.capsules.forEach((capsule) => {
          if (contentSourceIds.has(capsule.id) && capsule.lifecycle_environments) {
            capsule.lifecycle_environments.forEach((le) => {
              enabledLifecycleEnvironmentIds.add(le.id);
            });
          }
        });
      }
    });
  }

  const disabledEnvs = enabledLifecycleEnvironmentIds.size
    ? lifecycleEnvironments.filter(env => !enabledLifecycleEnvironmentIds.has(env.id))
    : [];

  const showAlert = disabledEnvs.length > 0;

  const affectedHostIds = (hostResponse?.results || []).map(host => host.id).join(',');

  const multiCVInfo = hostResponse?.results?.some?.(host =>
    host.content_facet_attributes?.multi_content_view_environment);

  const multiCVRemovalInfo = __('This content view version is used in one or more multi-environment hosts. The version will simply be removed from the multi-environment hosts. The content view and lifecycle environment you select here will only apply to single-environment hosts. See hammer activation-key --help for more details.');

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

  const onClear = () => {
    setSelectedCVForHosts(null);
    setSelectedCVNameForHosts(null);
  };

  const onSelect = (event, selection) => {
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
      {!alertDismissed && multiCVInfo && (
        <Alert
          ouiaId="multi-cv-info-alert"
          variant="info"
          isInline
          title={__('Multi-environment host(s) affected')}
          actionClose={<AlertActionCloseButton onClose={() => setAlertDismissed(true)} />}
        >
          <p>{multiCVRemovalInfo}</p>
        </Alert>
      )}
      {showAlert && (
        <Alert
          variant="info"
          ouiaId="disabled-environments-alert"
          isInline
          title={__('Some environments are disabled because they are not associated with all of the affected hosts\' content sources.')}
          style={{ marginBottom: '1rem' }}
        >
          <FormattedMessage
            id="hosts.changeContentSourcePrompt"
            defaultMessage="To enable them, add the environment to the hosts' content sources, or {link}."
            values={{
              link: (
                <a href={`/change_host_content_source?search=id ^ (${affectedHostIds})`}>
                  {__('assign a new content source to the hosts')}
                </a>
              ),
            }}
          />
        </Alert>
      )}
      <EnvironmentPaths
        userCheckedItems={selectedEnvForHost}
        setUserCheckedItems={setSelectedEnvForHost}
        publishing={false}
        headerText={__('Select lifecycle environment')}
        multiSelect={false}
        enabledLifecycleEnvironmentIds={enabledLifecycleEnvironmentIds}
      />
      <ContentViewSelect
        onClear={onClear}
        selections={selectedCVForHosts}
        onSelect={onSelect}
        isOpen={cvSelectOpen}
        isDisabled={disableCVSelect}
        onToggle={isExpanded => setCVSelectOpen(isExpanded)}
        id="selectCV"
        ouiaId="selectCV"
        name="selectCV"
        aria-label="selectCV"
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
