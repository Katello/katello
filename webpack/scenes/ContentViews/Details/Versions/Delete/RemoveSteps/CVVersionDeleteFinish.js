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
    setIsOpen, selected,
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
  const selectedEnv = versionEnvironments.filter((_env, index) => selected[index]);

  useDeepCompareEffect(() => {
    if (removeResolved && removeCVVersionResponse && removeDispatched) {
      setIsOpen(false);
      dispatch(getContentViewVersions(cvId));
    }
  }, [removeCVVersionResponse, removeResolved, setIsOpen, dispatch, cvId, removeDispatched]);

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
