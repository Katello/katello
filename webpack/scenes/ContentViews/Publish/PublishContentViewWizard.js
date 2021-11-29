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
import getContentViews from '../ContentViewsActions';
import getContentViewDetails from '../Details/ContentViewDetailActions';
import { stopPollingTask } from '../../Tasks/TaskActions';
import { cvVersionPublishKey } from '../ContentViewsConstants';

const PublishContentViewWizard = ({
  details, show, setIsOpen, currentStep, setCurrentStep,
}) => {
  const { name, id: cvId, version_count: versionCount } = details;
  const [description, setDescription] = useState('');
  const [userCheckedItems, setUserCheckedItems] = useState([]);
  const [promote, setPromote] = useState(false);
  const [forcePromote, setForcePromote] = useState([]);
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
        setIsOpen={setIsOpen}
        currentStep={currentStep}
        setCurrentStep={setCurrentStep}
      />,
      isFinishedStep: true,
    },
  ];

  useEffect(
    () => {
      dispatch(getEnvironmentPaths());
    },
    [dispatch],
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
      onClose={() => {
        setDescription('');
        setUserCheckedItems([]);
        setPromote(false);
        setForcePromote([]);
        if (currentStep === 3) {
          setCurrentStep(1);
          dispatch(getContentViewDetails(cvId));
          dispatch(getContentViews);
          dispatch(stopPollingTask(cvVersionPublishKey(cvId, versionCount)));
        }
        setIsOpen(false);
      }}
      isOpen={show}
    />
  );
};

PublishContentViewWizard.propTypes = {
  show: PropTypes.bool.isRequired,
  setIsOpen: PropTypes.func.isRequired,
  currentStep: PropTypes.number.isRequired,
  setCurrentStep: PropTypes.func.isRequired,
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
