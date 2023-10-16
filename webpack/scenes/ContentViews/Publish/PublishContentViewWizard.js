import React, { useEffect, useState, useMemo, useCallback } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import { STATUS } from 'foremanReact/constants';
import { Wizard } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import CVPublishForm from './CVPublishForm';
import CVPublishFinish from './CVPublishFinish';
import getEnvironmentPaths from '../components/EnvironmentPaths/EnvironmentPathActions';
import CVPublishReview from './CVPublishReview';
import {
  selectEnvironmentPaths,
  selectEnvironmentPathsStatus,
} from '../components/EnvironmentPaths/EnvironmentPathSelectors';
import { stopPollingTask } from '../../Tasks/TaskActions';
import { cvVersionTaskPollingKey } from '../ContentViewsConstants';
import { getContentViewFilters } from '../Details/ContentViewDetailActions';

const PublishContentViewWizard = ({
  details, show, onClose,
}) => {
  const { name, id: cvId, version_count: versionCount } = details;
  const POLLING_TASK_KEY = cvVersionTaskPollingKey(cvId);
  const [description, setDescription] = useState('');
  const [userCheckedItems, setUserCheckedItems] = useState([]);
  const [promote, setPromote] = useState(false);
  const [forcePromote, setForcePromote] = useState([]);
  const [currentStep, setCurrentStep] = useState(1);
  const dispatch = useDispatch();
  const environmentPathResponse = useSelector(selectEnvironmentPaths);
  const environmentPathStatus = useSelector(selectEnvironmentPathsStatus);
  const environmentPathLoading = environmentPathStatus === STATUS.PENDING;


  const steps = [
    {
      id: 1,
      name: __('Publish'),
      component: <CVPublishForm
        description={description}
        setDescription={setDescription}
        details={details}
        show={show}
        userCheckedItems={userCheckedItems}
        setUserCheckedItems={setUserCheckedItems}
        promote={promote}
        setPromote={setPromote}
        forcePromote={forcePromote}
      />,
    },
    {
      id: 2, name: __('Review details'), component: <CVPublishReview details={details} userCheckedItems={userCheckedItems} show={show} />, nextButtonText: 'Finish',
    },
    {
      id: 3,
      name: __('Finish'),
      component: <CVPublishFinish
        description={description}
        setDescription={setDescription}
        userCheckedItems={userCheckedItems}
        setUserCheckedItems={setUserCheckedItems}
        forcePromote={forcePromote}
        cvId={cvId}
        versionCount={versionCount}
        show={show}
        onClose={onClose}
        currentStep={currentStep}
      />,
      isFinishedStep: true,
    },
  ];

  useEffect(
    () => {
      dispatch(getEnvironmentPaths());
      dispatch(getContentViewFilters(cvId, {}));
    },
    [dispatch, cvId],
  );

  const envPathFlat = useMemo(() => {
    if (!environmentPathLoading) {
      const { results } = environmentPathResponse || {};
      return results.map(result => result.environments).flatten();
    }
    return [];
  }, [environmentPathResponse, environmentPathLoading]);

  const prior = useCallback(
    env => envPathFlat.find(item => item.id === env.prior.id),
    [envPathFlat],
  );
  const isChecked = useCallback(
    env => userCheckedItems.includes(env) || env.library,
    [userCheckedItems],
  );

  const isValid = useCallback((env) => {
    if (!env.prior) return true;
    if (!isChecked(prior(env))) return false;
    return isValid(prior(env));
  }, [prior, isChecked]);

  useEffect(() => {
    setForcePromote(userCheckedItems.filter(item => !isValid(item)));
  }, [userCheckedItems, setForcePromote, isValid]);

  return (
    <Wizard
      title={__('Publish')}
      description={currentStep === 3 ? __(`Publishing ${name}`) : __(`Determining settings for ${name}`)}
      steps={steps}
      startAtStep={currentStep}
      // Let the wizard handle step change
      onGoToStep={({ id }) => setCurrentStep(id)}
      onNext={({ id }) => setCurrentStep(id)}
      onBack={({ id }) => setCurrentStep(id)}
      onClose={() => {
        if (currentStep === 3) {
          dispatch(stopPollingTask(POLLING_TASK_KEY));
          onClose(true);
        } else onClose();
      }}
      isOpen={show}
      id="content-view-publish-wizard"
    />
  );
};

PublishContentViewWizard.propTypes = {
  show: PropTypes.bool.isRequired,
  onClose: PropTypes.func.isRequired,
  details: PropTypes.shape({
    id: PropTypes.oneOfType([
      PropTypes.number,
      PropTypes.string,
    ]),
    name: PropTypes.string,
    version_count: PropTypes.number,
  }).isRequired,
};

export default PublishContentViewWizard;
