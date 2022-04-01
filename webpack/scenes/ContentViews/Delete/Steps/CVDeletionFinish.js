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
    cvId,
    cvEnvironments,
    setIsOpen,
    selectedCVForAK, selectedEnvForAK, selectedCVForHosts,
    selectedEnvForHost, affectedActivationKeys, affectedHosts,
  } = useContext(CVDeleteContext);
  const removeCVResponse = useSelector(state =>
    selectRemoveCVVersionResponse(state, cvId, cvEnvironments));
  const removeCVStatus = useSelector(state =>
    selectRemoveCVVersionStatus(state, cvId, cvEnvironments));
  const dispatch = useDispatch();
  const [removeDispatched, setRemoveDispatched] = useState(false);
  const { push, location: { pathname } } = useHistory();

  useDeepCompareEffect(() => {
    // If there is an error, we still want to refresh or redirect to show it.
    if (removeDispatched && removeCVStatus === STATUS.ERROR) {
      if (pathname === '/content_views') dispatch(getContentViews());
      else push('/content_views');
      setIsOpen(false);
    }
  }, [dispatch, pathname, push, removeCVStatus, removeDispatched, setIsOpen]);

  useDeepCompareEffect(() => {
    if (!removeDispatched) {
      let params = {
        id: cvId,
        destroy_content_view: true,
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

      dispatch(removeContentViewVersion(
        cvId, cvId, cvEnvironments, params,
        // Only when we are on the contentViews page do we need to call getContentViews.
        () => {
          if (pathname === '/content_views') dispatch(getContentViews());
          else push('/content_views');
          setIsOpen(false);
        },
        () => {
          setIsOpen(false);
        },
      ));
      setRemoveDispatched(true);
    }
  }, [cvId, cvEnvironments, dispatch, affectedActivationKeys, affectedHosts,
    selectedCVForAK, selectedCVForHosts, selectedEnvForAK, selectedEnvForHost,
    removeCVResponse, removeCVStatus, removeDispatched, pathname, push, setIsOpen]);

  return <Loading loadingText={__('Please wait while the task starts..')} />;
};

export default CVDeletionFinish;
