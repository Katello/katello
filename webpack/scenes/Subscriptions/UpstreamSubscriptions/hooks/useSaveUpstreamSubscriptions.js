import React, { useCallback, useEffect, useRef, useState } from 'react';
import _ from 'lodash';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import { STATUS } from 'foremanReact/constants';
import api, { orgId } from '../../../../services/api';
import { getResponseErrorMsgs } from '../../../../utils/helpers';
import { SAVE_UPSTREAM_SUBSCRIPTIONS_KEY } from '../UpstreamSubscriptionsConstants';

const useSaveUpstreamSubscriptions = ({ selectedRows, history }) => {
  const [saveParams, setSaveParams] = useState(null);

  const saveUrl = api.getApiUrl(`/organizations/${orgId()}/upstream_subscriptions`);
  const saveErrorToast = useCallback(
    error => getResponseErrorMsgs(error.response),
    [],
  );

  const { response: saveResponse, status: saveStatus, setAPIOptions: setSaveAPIOptions } = useAPI(
    saveParams ? 'post' : null,
    saveUrl,
    {
      key: SAVE_UPSTREAM_SUBSCRIPTIONS_KEY,
      errorToast: saveErrorToast,
    },
  );

  const handleSaveSuccess = useCallback((task) => {
    const message = (
      <span>
        <span>{__('Subscriptions have been saved and are being updated. ')}</span>
        <a href={urlBuilder('foreman_tasks/tasks', '', task.id)}>
          {__('Click here to go to the tasks page for the task.')}
        </a>
      </span>
    );

    window.tfm.toastNotifications.notify({ message, type: 'success' });
    history.push('/subscriptions');
  }, [history]);

  const prevSaveStatusRef = useRef(saveStatus);

  useEffect(() => {
    const prevSaveStatus = prevSaveStatusRef.current;

    if (saveStatus === STATUS.RESOLVED && prevSaveStatus === STATUS.PENDING && saveResponse) {
      handleSaveSuccess(saveResponse);
      setSaveParams(null);
    } else if (saveStatus === STATUS.ERROR && prevSaveStatus === STATUS.PENDING) {
      setSaveParams(null);
    }

    prevSaveStatusRef.current = saveStatus;
  }, [saveStatus, saveResponse, handleSaveSuccess]);

  const isSaving = saveParams !== null && saveStatus === STATUS.PENDING;

  const saveUpstreamSubscriptions = useCallback(() => {
    const updatedPools = _.map(
      selectedRows,
      pool => ({ id: pool.id, quantity: parseInt(pool.updatedQuantity, 10) }),
    );
    const params = { pools: updatedPools };

    setSaveAPIOptions({
      params,
      errorToast: saveErrorToast,
    });
    setSaveParams(params);
  }, [selectedRows, setSaveAPIOptions, saveErrorToast]);

  return {
    saveUpstreamSubscriptions,
    isSaving,
  };
};

export default useSaveUpstreamSubscriptions;
