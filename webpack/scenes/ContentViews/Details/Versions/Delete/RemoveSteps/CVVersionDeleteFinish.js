import React, { useState, useEffect, useContext } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useHistory } from 'react-router-dom';
import { STATUS } from 'foremanReact/constants';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { translate as __ } from 'foremanReact/common/I18n';
import api from 'foremanReact/API';
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
    selectedCVForHostgroups, selectedEnvForHostgroup, affectedHostgroups,
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

      const buildParamsAndDispatch = async () => {
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

        if (affectedHostgroups) {
          // Fetch the CVEnv ID for the selected CV and environment
          const response = await api.get('/katello/api/v2/content_view_environments', {}, {
            content_view_id: selectedCVForHostgroups,
            lifecycle_environment_id: selectedEnvForHostgroup[0].id,
          });
          const cvEnvId = response.data?.results?.[0]?.id;
          if (cvEnvId) {
            params = {
              ...params,
              hostgroup_content_view_environment_id: cvEnvId,
            };
          }
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
      };

      buildParamsAndDispatch();
    }
  }, [affectedActivationKeys, affectedHosts, affectedHostgroups, cvId, deleteFlow,
    dispatch, pathname, push, removeDeletionFlow, removeDispatched,
    selectedCVForAK, selectedCVForHosts, selectedCVForHostgroups,
    selectedEnv, selectedEnvForAK, selectedEnvForHost, selectedEnvForHostgroup,
    setIsOpen, versionEnvironments, versionIdToRemove]);

  return <Loading loadingText={__('Please wait while the task starts..')} />;
};

export default CVVersionDeleteFinish;
