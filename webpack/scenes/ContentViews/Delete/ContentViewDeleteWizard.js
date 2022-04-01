import React, { useEffect, useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { Wizard } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import CVDeleteEnvironmentSelection from './Steps/CVDeleteEnvironmentsSelection';
import {
  selectCVDetails,
  selectCVDetailStatus,
  selectCVVersions,
  selectCVVersionsStatus,
} from '../Details/ContentViewDetailSelectors';
import getEnvironmentPaths from '../components/EnvironmentPaths/EnvironmentPathActions';
import getContentViewDetails, { getContentViewVersions } from '../Details/ContentViewDetailActions';
import CVDeletionReassignHostsForm from './Steps/CVDeletionReassignHostsForm';
import CVDeletionReassignActivationKeysForm from './Steps/CVDeletionReassignActivationKeysForm';
import CVDeletionReview from './Steps/CVDeletionReview';
import CVDeletionFinish from './Steps/CVDeletionFinish';
import CVDeleteContext from './CVDeleteContext';
import Loading from '../../../components/Loading';

const ContentViewDeleteWizard =
  ({
    cvId, cvEnvironments, show, setIsOpen,
  }) => {
    const cvVersionResponse = useSelector(state => selectCVVersions(state, cvId));
    const cvVersionStatus = useSelector(state => selectCVVersionsStatus(state, cvId));
    const cvDetailsResponse = useSelector(state => selectCVDetails(state, cvId));
    const cvDetailsStatus = useSelector(state => selectCVDetailStatus(state, cvId));
    const [selectedEnvForAK, setSelectedEnvForAK] = useState([]);
    const [selectedEnvForHost, setSelectedEnvForHost] = useState([]);
    const dispatch = useDispatch();
    const [selectedCVForAK, setSelectedCVForAK] = useState(null);
    const [selectedCVNameForAK, setSelectedCVNameForAK] = useState(null);
    const [selectedCVForHosts, setSelectedCVForHosts] = useState(null);
    const [selectedCVNameForHosts, setSelectedCVNameForHosts] = useState(null);
    const [affectedActivationKeys, setAffectedActivationKeys] = useState(false);
    const [affectedHosts, setAffectedHosts] = useState(false);
    const [canReview, setCanReview] = useState(false);
    const [currentStep, setCurrentStep] = useState(1);

    const { name } = cvDetailsResponse ?? {};

    useEffect(
      () => {
        if (cvDetailsStatus !== STATUS.RESOLVED) { dispatch(getContentViewDetails(cvId)); }
        if (cvVersionStatus !== STATUS.RESOLVED) { dispatch(getContentViewVersions(cvId)); }
        dispatch(getEnvironmentPaths());
      },
      // We don't want to call this everytime the status changes
      // eslint-disable-next-line react-hooks/exhaustive-deps
      [cvId, dispatch],
    );

    useEffect(() => {
      const hostsStepComplete = affectedHosts ?
        selectedEnvForHost && selectedCVForHosts :
        true;
      const activationStepComplete = affectedActivationKeys ?
        selectedEnvForAK && selectedCVForAK :
        true;
      setCanReview(hostsStepComplete && activationStepComplete);
    }, [affectedHosts, selectedEnvForHost, selectedCVForHosts,
      affectedActivationKeys, selectedEnvForAK, selectedCVForAK]);

    const environmentSelectionStep = {
      id: 1,
      name: __('Remove versions from environments'),
      component: <CVDeleteEnvironmentSelection />,
    };
    const affectedHostsStep = {
      id: 2,
      name: __('Reassign affected hosts'),
      component: <CVDeletionReassignHostsForm />,
    };
    const affectedKeysStep = {
      id: 3,
      name: __('Reassign affected activation keys'),
      component: <CVDeletionReassignActivationKeysForm />,
      enableNext: canReview,
    };
    const reviewStep = {
      id: 4,
      name: __('Review details'),
      component: <CVDeletionReview />,
      canJumpTo: canReview,
      nextButtonText: __('Delete'),
    };
    const finishStep = {
      id: 5,
      name: __('Delete'),
      component: <CVDeletionFinish />,
      isFinishedStep: true,
    };

    useDeepCompareEffect(() => {
      if (!(cvVersionStatus === STATUS.LOADING || cvDetailsStatus === STATUS.LOADING)) {
        const { activation_keys: keys, hosts } = cvDetailsResponse;
        setAffectedHosts(!!(hosts?.length));
        setAffectedActivationKeys(!!(keys?.length));
      }
    }, [cvVersionResponse, cvVersionStatus, cvDetailsResponse, cvDetailsStatus]);

    const steps = [
      environmentSelectionStep,
      ...(affectedHosts ? [affectedHostsStep] : []),
      ...(affectedActivationKeys ? [affectedKeysStep] : []),
      reviewStep,
      finishStep,
    ];

    if (cvVersionStatus === STATUS.LOADING || cvDetailsStatus === STATUS.LOADING) {
      return <Loading />;
    }
    return (
      <CVDeleteContext.Provider value={{
        cvId,
        cvEnvironments,
        show,
        setIsOpen,
        currentStep,
        setCurrentStep,
        cvVersionResponse,
        cvVersionStatus,
        cvDetailsResponse,
        cvDetailsStatus,
        selectedEnvForAK,
        setSelectedEnvForAK,
        selectedEnvForHost,
        setSelectedEnvForHost,
        selectedCVForAK,
        setSelectedCVForAK,
        selectedCVNameForAK,
        setSelectedCVNameForAK,
        selectedCVForHosts,
        setSelectedCVForHosts,
        selectedCVNameForHosts,
        setSelectedCVNameForHosts,
        affectedActivationKeys,
        affectedHosts,
      }}
      >
        <Wizard
          title={__('Delete content view')}
          description={<>{__('Deleting content view : ')}<b>{name}</b></>}
          steps={steps}
          startAtStep={currentStep}
          onClose={() => {
            setIsOpen(false);
          }}
          isOpen={show}
        />
      </CVDeleteContext.Provider>
    );
  };

ContentViewDeleteWizard.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  cvEnvironments: PropTypes.arrayOf(PropTypes.shape({})),
  show: PropTypes.bool,
  setIsOpen: PropTypes.func,
};

ContentViewDeleteWizard.defaultProps = {
  cvEnvironments: [],
  show: false,
  setIsOpen: null,
};

export default ContentViewDeleteWizard;
