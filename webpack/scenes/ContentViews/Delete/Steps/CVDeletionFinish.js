import React, { useContext, useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { useHistory } from 'react-router-dom';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { removeContentViewVersion } from '../../Details/ContentViewDetailActions';
import { selectRemoveCVVersionResponse, selectRemoveCVVersionStatus } from '../../Details/ContentViewDetailSelectors';
import getContentViews from '../../ContentViewsActions';
import CVDeleteContext from '../CVDeleteContext';
import Loading from '../../../../components/Loading';

const CVDeletionFinish = () => {
  const {
    cvId, cvEnvironments,
    setIsOpen,
    selectedCVForAK, selectedEnvForAK, selectedCVForHosts,
    selectedEnvForHost, affectedActivationKeys, affectedHosts,
  } = useContext(CVDeleteContext);
  const removeCVResponse = useSelector(state =>
    selectRemoveCVVersionResponse(state, cvId, cvEnvironments));
  const removeCVStatus = useSelector(state =>
    selectRemoveCVVersionStatus(state, cvId, cvEnvironments));
  const removeResolved = removeCVStatus === STATUS.RESOLVED;
  const dispatch = useDispatch();
  const [removeDispatched, setRemoveDispatched] = useState(false);
  const { push } = useHistory();

  useDeepCompareEffect(() => {
    if (removeResolved && removeDispatched) {
      dispatch(getContentViews());
      push('/content_views');
      setIsOpen(false);
    }
    if (removeCVStatus === STATUS.ERROR) {
      setIsOpen(false);
    }
  }, [removeCVResponse, removeCVStatus, removeResolved,
    setIsOpen, dispatch, cvId, removeDispatched, push]);

  useDeepCompareEffect(() => {
    if (!removeDispatched) {
      let params = {
        id: cvId,
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

      const deletionParams = { destroy_content_view: true };
      params = { ...deletionParams, ...params };
      dispatch(removeContentViewVersion(cvId, cvId, cvEnvironments, params));
      setRemoveDispatched(true);
    }
  }, [cvId, cvEnvironments, dispatch, affectedActivationKeys,
    affectedHosts, selectedCVForAK, selectedCVForHosts,
    selectedEnvForAK, selectedEnvForHost, removeCVResponse, removeCVStatus, removeDispatched]);

  return <Loading loadingText={__('Please wait while the task starts..')} />;
};

export default CVDeletionFinish;
