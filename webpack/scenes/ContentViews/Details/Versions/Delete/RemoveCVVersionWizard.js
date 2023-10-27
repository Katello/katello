import React, { useEffect, useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { Wizard } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { useSet } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import getEnvironmentPaths from '../../../components/EnvironmentPaths/EnvironmentPathActions';
import CVEnvironmentSelectionForm from './RemoveSteps/CVEnvironmentSelectionForm';
import CVReassignActivationKeysForm from './RemoveSteps/CVReassignActivationKeysForm';
import CVReassignHostsForm from './RemoveSteps/CVReassignHostsForm';
import CVVersionRemoveReview from './RemoveSteps/CVVersionRemoveReview';
import CVVersionDeleteFinish from './RemoveSteps/CVVersionDeleteFinish';
import getContentViewDetails from '../../ContentViewDetailActions';
import getContentViews from '../../../ContentViewsActions';
import DeleteContext from './DeleteContext';

const RemoveCVVersionWizard = ({
  cvId, versionIdToRemove, versionNameToRemove,
  versionEnvironments, show, setIsOpen,
  currentStep, setCurrentStep, deleteWizard,
}) => {
  const [selectedEnvForAK, setSelectedEnvForAK] = useState([]);
  const [selectedEnvForHost, setSelectedEnvForHost] = useState([]);
  const dispatch = useDispatch();
  const selectedEnvSet = useSet([]);
  const [selectedCVForAK, setSelectedCVForAK] = useState(null);
  const [selectedCVNameForAK, setSelectedCVNameForAK] = useState(null);
  const [selectedCVForHosts, setSelectedCVForHosts] = useState(null);
  const [selectedCVNameForHosts, setSelectedCVNameForHosts] = useState(null);
  const [affectedActivationKeys, setAffectedActivationKeys] = useState(false);
  const [affectedHosts, setAffectedHosts] = useState(false);
  const [deleteFlow, setDeleteFlow] = useState(deleteWizard || false);
  const [removeDeletionFlow, setRemoveDeletionFlow] = useState(false);
  const [canReview, setCanReview] = useState(false);

  useEffect(
    () => {
      dispatch(getEnvironmentPaths());
      if (deleteFlow) {
        versionEnvironments.forEach(env => selectedEnvSet.add(env.id));
      }
      if (versionEnvironments.length === 0) setDeleteFlow(true);
    },
    [dispatch, deleteFlow, setDeleteFlow, versionEnvironments, selectedEnvSet],
  );

  useEffect(() => {
    const hostsStepComplete = affectedHosts ?
      selectedEnvForHost && selectedCVForHosts :
      true;
    const activationStepComplete = affectedActivationKeys ?
      selectedEnvForAK && selectedCVForAK :
      true;
    setCanReview(hostsStepComplete &&
      activationStepComplete &&
      (selectedEnvSet.size || versionEnvironments.length === 0));
  }, [affectedHosts, selectedEnvForHost, selectedCVForHosts, versionEnvironments,
    affectedActivationKeys, selectedEnvForAK, selectedCVForAK, selectedEnvSet.size]);

  const environmentSelectionStep = {
    id: 1,
    name: __('Remove from environments'),
    component: <CVEnvironmentSelectionForm />,
    enableNext: (selectedEnvSet.size || versionEnvironments.length === 0),
  };

  const hostStep = {
    id: 2,
    name: 'Reassign affected hosts',
    component: <CVReassignHostsForm />,
    enableNext: (affectedHosts ? selectedEnvForHost && selectedCVForHosts : true),
    canJumpTo: affectedHosts,
  };

  const activationStep = {
    id: 3,
    name: 'Reassign affected activation keys',
    component: <CVReassignActivationKeysForm />,
    enableNext: canReview,
    canJumpTo: affectedActivationKeys &&
      (affectedHosts ? selectedEnvForHost && selectedCVForHosts : true),
  };

  const reviewStep = {
    id: 4,
    name: 'Review',
    component: <CVVersionRemoveReview />,
    canJumpTo: canReview,
    nextButtonText: deleteFlow ? __('Delete') : __('Remove'),
  };

  const finishStep = {
    id: 5,
    name: 'Finish',
    component: <CVVersionDeleteFinish />,
    isFinishedStep: true,
  };

  const steps = [
    environmentSelectionStep,
    ...(affectedHosts ? [hostStep] : []),
    ...(affectedActivationKeys ? [activationStep] : []),
    reviewStep,
    finishStep,
  ];

  return (
    <DeleteContext.Provider value={{
      cvId,
      versionIdToRemove,
      versionNameToRemove,
      versionEnvironments,
      setIsOpen,
      affectedActivationKeys,
      affectedHosts,
      setAffectedActivationKeys,
      setAffectedHosts,
      deleteFlow,
      setDeleteFlow,
      removeDeletionFlow,
      setRemoveDeletionFlow,
      currentStep,
      selectedCVForHosts,
      setSelectedCVNameForHosts,
      setSelectedCVForHosts,
      selectedCVForAK,
      setSelectedCVNameForAK,
      selectedCVNameForAK,
      selectedCVNameForHosts,
      setSelectedCVForAK,
      selectedEnvForAK,
      setSelectedEnvForAK,
      selectedEnvForHost,
      setSelectedEnvForHost,
      selectedEnvSet,
    }}
    >
      <Wizard
        title={deleteFlow ? __('Delete Version') : __('Remove Version')}
        description={__(`${deleteFlow ? 'Deleting' : 'Removing'} version ${versionNameToRemove}`)}
        steps={steps}
        startAtStep={currentStep}
        onClose={() => {
          selectedEnvSet.clear();
          if (currentStep === 3) {
            setCurrentStep(1);
            dispatch(getContentViewDetails(cvId));
            dispatch(getContentViews);
          }
          setIsOpen(false);
        }}
        isOpen={show}
      />
    </DeleteContext.Provider>
  );
};

RemoveCVVersionWizard.propTypes = {
  cvId: PropTypes.number.isRequired,
  versionIdToRemove: PropTypes.number.isRequired,
  versionNameToRemove: PropTypes.string.isRequired,
  versionEnvironments: PropTypes.arrayOf(PropTypes.shape({})),
  show: PropTypes.bool,
  setIsOpen: PropTypes.func,
  currentStep: PropTypes.number.isRequired,
  setCurrentStep: PropTypes.func.isRequired,
  deleteWizard: PropTypes.bool.isRequired,
};

RemoveCVVersionWizard.defaultProps = {
  versionEnvironments: [],
  show: false,
  setIsOpen: null,
};

export default RemoveCVVersionWizard;
