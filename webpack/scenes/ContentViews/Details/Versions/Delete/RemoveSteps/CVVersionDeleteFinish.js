import React, { useState, useContext } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectRemoveCVVersionResponse, selectRemoveCVVersionStatus } from '../../../ContentViewDetailSelectors';
import { getContentViewVersions, removeContentViewVersion } from '../../../ContentViewDetailActions';
import Loading from '../../../../../../components/Loading';
import DeleteContext from '../DeleteContext';

const CVVersionDeleteFinish = () => {
  const {
    cvId, versionIdToRemove, versionEnvironments,
    setIsOpen, selectedEnvSet,
    selectedCVForAK, selectedEnvForAK, selectedCVForHosts,
    selectedEnvForHost, affectedActivationKeys, affectedHosts, deleteFlow, removeDeletionFlow,
  } = useContext(DeleteContext);
  const removeCVVersionResponse = useSelector(state =>
    selectRemoveCVVersionResponse(state, versionIdToRemove, versionEnvironments));
  const removeCVVersionStatus = useSelector(state =>
    selectRemoveCVVersionStatus(state, versionIdToRemove, versionEnvironments));
  const removeResolved = removeCVVersionStatus === STATUS.RESOLVED;
  const dispatch = useDispatch();
  const [removeDispatched, setRemoveDispatched] = useState(false);
  const selectedEnv = versionEnvironments.filter(env => selectedEnvSet.has(env.id));

  useDeepCompareEffect(() => {
    if (removeResolved && removeCVVersionResponse && removeDispatched) {
      setIsOpen(false);
      dispatch(getContentViewVersions(cvId));
    }
  }, [removeCVVersionResponse, removeResolved, setIsOpen, dispatch, cvId, removeDispatched]);

  /*
    The remove version from environment API takes the following params :
     id: Content View to remove from environments
     environment_ids: List of environments to remove CV from

     If activation keys need to be reassigned, we need to pass:
     key_content_view_id : New Content view for activation keys
     key_environment_id: Environment of the CV we are reassigning keys to

     Additionally, if hosts need to be reassigned, we need to pass:
     system_content_view_id: New Content view for Hosts
     system_environment_id: Environment of the CV we are reassigning hosts to

    Finally, if we want to delete the version after removing it from all environments,
    we need to pass content_view_version_ids param, that accepts an array of versions to delete

    This hook forms the params based on selections made in the wizard and dispatches the call.
  */
  useDeepCompareEffect(() => {
    if (!removeDispatched) {
      const environmentIdParams = (deleteFlow || removeDeletionFlow) ?
        versionEnvironments.map(env => env.id) :
        selectedEnv.map(env => env.id);

      let params = {
        id: cvId,
        environment_ids: environmentIdParams,
      };

      if (affectedActivationKeys) {
        const activationKeysParams = {
          key_content_view_id: selectedCVForAK,
          key_environment_id: selectedEnvForAK[0].id,
        };
        params = { ...activationKeysParams, ...params };
      }

      if (affectedHosts) {
        const hostParams = {
          system_content_view_id: selectedCVForHosts,
          system_environment_id: selectedEnvForHost[0].id,
        };
        params = { ...hostParams, ...params };
      }

      if (deleteFlow || removeDeletionFlow) {
        const deletionParams = { content_view_version_ids: [versionIdToRemove] };
        params = { ...deletionParams, ...params };
      }
      dispatch(removeContentViewVersion(cvId, versionIdToRemove, versionEnvironments, params));
      setRemoveDispatched(true);
    }
  }, [cvId, versionIdToRemove, versionEnvironments, dispatch, affectedActivationKeys,
    affectedHosts, deleteFlow, removeDeletionFlow, selectedCVForAK, selectedCVForHosts,
    selectedEnvForAK, selectedEnvForHost, selectedEnv,
    removeCVVersionResponse, removeCVVersionStatus, removeDispatched]);

  return <Loading loadingText={__('Please wait while the task starts..')} />;
};

export default CVVersionDeleteFinish;
