import React, { useState, useEffect, useContext } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useHistory } from 'react-router-dom';
import { STATUS } from 'foremanReact/constants';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectRemoveCVVersionStatus } from '../../../ContentViewDetailSelectors';
import getContentViewDetails, { removeContentViewVersion } from '../../../ContentViewDetailActions';
import Loading from '../../../../../../components/Loading';
import DeleteContext from '../DeleteContext';

const CVVersionDeleteFinish = () => {
  const {
    cvId, versionIdToRemove, versionEnvironments,
    setIsOpen, selectedEnvSet,
    selectedCVForAK, selectedEnvForAK, selectedCVForHosts,
    selectedEnvForHost, affectedActivationKeys, affectedHosts,
    deleteFlow, removeDeletionFlow,
  } = useContext(DeleteContext);

  const dispatch = useDispatch();
  const removeCVVersionStatus = useSelector(state =>
    selectRemoveCVVersionStatus(state, versionIdToRemove, versionEnvironments));
  const [removeDispatched, setRemoveDispatched] = useState(false);
  const selectedEnv = versionEnvironments.filter(env => selectedEnvSet.has(env.id));
  const { push, location: { pathname } } = useHistory();

  useEffect(() => {
    if (removeCVVersionStatus === STATUS.ERROR) {
      setIsOpen(false);
    }
  }, [setIsOpen, removeCVVersionStatus]);


  useDeepCompareEffect(() => {
    if (!removeDispatched) {
      setRemoveDispatched(true);

      const environmentIdParams = (deleteFlow || removeDeletionFlow) ?
        versionEnvironments.map(env => env.id) :
        selectedEnv.map(env => env.id);

      let params = {
        id: cvId,
        environment_ids: environmentIdParams,
      };

      if (affectedActivationKeys) {
        params = {
          ...params,
          key_content_view_id: selectedCVForAK,
          key_environment_id: selectedEnvForAK[0].id,
        };
      }

      if (affectedHosts) {
        params = {
          ...params,
          system_content_view_id: selectedCVForHosts,
          system_environment_id: selectedEnvForHost[0].id,
        };
      }

      if (deleteFlow || removeDeletionFlow) {
        params = {
          ...params,
          content_view_version_ids: [versionIdToRemove],
        };
      }

      dispatch(removeContentViewVersion(
        cvId,
        versionIdToRemove,
        versionEnvironments,
        params,
        () => {
          dispatch(getContentViewDetails(cvId));
          if (pathname !== '/versions') push('/versions');
        },
      ));
    }
  }, [affectedActivationKeys, affectedHosts, cvId, deleteFlow,
    dispatch, pathname, push, removeDeletionFlow, removeDispatched,
    selectedCVForAK, selectedCVForHosts, selectedEnv, selectedEnvForAK,
    selectedEnvForHost, setIsOpen, versionEnvironments, versionIdToRemove]);

  return <Loading loadingText={__('Please wait while the task starts..')} />;
};

export default CVVersionDeleteFinish;
