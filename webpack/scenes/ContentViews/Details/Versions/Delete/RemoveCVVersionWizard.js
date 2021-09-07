import React, { useEffect, useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { Wizard } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
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
  const [selected, setSelected] = useState(deleteWizard ?
    versionEnvironments.map(_row => true) :
    versionEnvironments.map(_row => false));
  const [selectedCVForAK, setSelectedCVForAK] = useState(null);
  const [selectedCVNameForAK, setSelectedCVNameForAK] = useState(null);
  const [selectedCVForHosts, setSelectedCVForHosts] = useState(null);
  const [selectedCVNameForHosts, setSelectedCVNameForHosts] = useState(null);
  const [affectedActivationKeys, setAffectedActivationKeys] = useState(false);
  const [affectedHosts, setAffectedHosts] = useState(false);
  const [deleteFlow, setDeleteFlow] = useState(deleteWizard || false);

  const canReview = () => {
    const hostsStepComplete = affectedHosts ?
      selectedEnvForHost && selectedCVForHosts :
      true;
    const activationStepComplete = affectedActivationKeys ?
      selectedEnvForAK && selectedCVForAK :
      true;
    return hostsStepComplete && activationStepComplete && selected.filter(val => val).length;
  };

  const environmentSelectionStep = {
    id: 1,
    name: __('Remove from environments'),
    component: <CVEnvironmentSelectionForm />,
  };

  const hostStep = {
    id: 2,
    name: 'Reassign affected hosts',
    component: <CVReassignHostsForm />,
    canJumpTo: affectedHosts,
  };

  const activationStep = {
    id: 3,
    name: 'Reassign affected activation keys',
    component: <CVReassignActivationKeysForm />,
    canJumpTo: affectedActivationKeys &&
    (affectedHosts ? selectedEnvForHost && selectedCVForHosts : true),
  };

  const reviewStep = {
    id: 4,
    name: 'Review',
    component: <CVVersionRemoveReview />,
    canJumpTo: canReview(),
    nextButtonText: __('Remove'),
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

  useEffect(
    () => {
      dispatch(getEnvironmentPaths());
    },
    [dispatch],
  );

  return (
    <DeleteContext.Provider value={{
      cvId,
      versionIdToRemove,
      versionNameToRemove,
      versionEnvironments,
      setIsOpen,
      selected,
      setSelected,
      affectedActivationKeys,
      affectedHosts,
      setAffectedActivationKeys,
      setAffectedHosts,
      deleteFlow,
      setDeleteFlow,
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
    }}
    >
      <Wizard
        title={__('Remove Version')}
        description={__(`Removing version ${versionNameToRemove}`)}
        steps={steps}
        startAtStep={currentStep}
        onClose={() => {
          setSelected([]);
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
