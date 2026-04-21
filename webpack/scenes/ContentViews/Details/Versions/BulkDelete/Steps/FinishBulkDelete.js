import React, { useContext } from 'react';

import { translate as __ } from 'foremanReact/common/I18n';
import { first } from 'lodash';
import {
  useDispatch,
} from 'react-redux';
import useDeepCompareEffect from 'use-deep-compare-effect';

import api from 'foremanReact/API';
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
    selectedEnvForHostgroups,
    selectedCVForHostgroups,
  } = useContext(BulkDeleteContext);
  const { content_view: { id: cvId } } = first(versions);

  const dispatch = useDispatch();

  // Call the remove api on load
  useDeepCompareEffect(() => {
    const performBulkDelete = async () => {
      const params = {
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
      };

      if (selectedCVForHostgroups && selectedEnvForHostgroups?.length > 0) {
        // Fetch the CVEnv ID for the selected CV and environment
        const response = await api.get('/katello/api/v2/content_view_environments', {}, {
          content_view_id: selectedCVForHostgroups,
          lifecycle_environment_id: first(selectedEnvForHostgroups)?.id,
        });
        const cvEnvId = response.data?.results?.[0]?.id;
        if (cvEnvId) {
          params.hostgroup_content_view_environment_id = cvEnvId;
        }
      }

      dispatch(bulkDeleteContentViewVersion(
        cvId,
        params,
        // Callback to update on success
        () => {
          onClose(true);
          dispatch(getContentViewDetails(cvId));
        },
        // onError
        () => { onClose(true); },
      ));
    };

    performBulkDelete();
  }, [dispatch, cvId, versions,
    selectedCVForHosts, selectedEnvForHosts, selectedCVForAK, selectedEnvForAK,
    selectedCVForHostgroups, selectedEnvForHostgroups, onClose]);


  return <Loading loadingText={__('Please wait while the task starts..')} />;
};

