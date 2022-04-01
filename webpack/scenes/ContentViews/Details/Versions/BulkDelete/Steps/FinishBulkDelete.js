import React, { useContext } from 'react';

import { translate as __ } from 'foremanReact/common/I18n';
import { first } from 'lodash';
import {
  useDispatch,
} from 'react-redux';
import useDeepCompareEffect from 'use-deep-compare-effect';

import Loading from '../../../../../../components/Loading';
import getContentViewDetails, {
  bulkDeleteContentViewVersion,
} from '../../../ContentViewDetailActions';

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
      () => {
        onClose(true);
        dispatch(getContentViewDetails(cvId));
      },
      // onError
      () => { onClose(true); },
    ));
  }, [dispatch, cvId, versions,
    selectedCVForHosts, selectedEnvForHosts, selectedCVForAK, selectedEnvForAK, onClose]);


  return <Loading loadingText={__('Please wait while the task starts..')} />;
};

