import React, { useContext } from 'react';

import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { first } from 'lodash';
import {
  useDispatch,
  useSelector,
} from 'react-redux';
import useDeepCompareEffect from 'use-deep-compare-effect';

import Loading from '../../../../../../components/Loading';
import {
  bulkDeleteContentViewVersion,
  getContentViewVersions,
} from '../../../ContentViewDetailActions';
import {
  selectBulkRemoveCVVersionResponse,
  selectBulkRemoveCVVersionStatus,
} from '../../../ContentViewDetailSelectors';
import { BulkDeleteContext } from '../BulkDeleteContextWrapper';

export default () => {
  const {
    onClose,
    versions,
    selectedEnvForAK,
    selectedCVForAK,
    selectedEnvForHosts,
    selectedCVForHosts,
  } = useContext(BulkDeleteContext);
  const { content_view: { id: cvId } } = first(versions);
  const bulkRemoveCVVersionResponse = useSelector(state =>
    selectBulkRemoveCVVersionResponse(state, cvId));
  const bulkRemoveCVVersionStatus = useSelector(state =>
    selectBulkRemoveCVVersionStatus(state, cvId));

  const dispatch = useDispatch();

  // Call the remove api on load
  useDeepCompareEffect(() => {
    dispatch(bulkDeleteContentViewVersion(
      cvId,
      {
        bulk_content_view_version_ids: {
          included: {
            ids: versions.map(({ id }) => id),
          },
          excluded: {},
        },
        id: cvId,
        system_content_view_id: selectedCVForHosts ?? undefined,
        system_environment_id: first(selectedEnvForHosts)?.id ?? undefined,
        key_content_view_id: selectedCVForAK ?? undefined,
        key_environment_id: first(selectedEnvForAK)?.id ?? undefined,
      },
      // Callback to update on success
      () => dispatch(getContentViewVersions(cvId)),
    ));
  }, [dispatch, cvId, versions, selectedCVForHosts,
    selectedEnvForHosts, selectedCVForAK, selectedEnvForAK]);

  useDeepCompareEffect(() => {
    if (!!bulkRemoveCVVersionResponse &&
      bulkRemoveCVVersionStatus !== STATUS.PENDING) {
      onClose(true);
      // Send true in the onClose callback to know when to redirect on other pages
    }
  }, [dispatch, cvId, bulkRemoveCVVersionResponse, bulkRemoveCVVersionStatus, onClose]);

  return <Loading loadingText={__('Please wait while the task starts..')} />;
};

