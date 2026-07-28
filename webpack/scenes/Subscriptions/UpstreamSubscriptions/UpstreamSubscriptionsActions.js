import React from 'react';
import { APIActions } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import api, { orgId } from '../../../services/api';
import { apiError, getResponseErrorMsgs } from '../../../utils/helpers';
import {
  SAVE_UPSTREAM_SUBSCRIPTIONS_KEY,
  PING_UPSTREAM_SUBSCRIPTIONS_KEY,
  PING_UPSTREAM_SUBSCRIPTIONS_SUCCESS,
  PING_UPSTREAM_SUBSCRIPTIONS_FAILURE,
} from './UpstreamSubscriptionsConstants';

const saveSuccessToast = (response) => {
  const task = response.data;

  return (
    <span>
      <span>{__('Subscriptions have been saved and are being updated. ')}</span>
      <a href={urlBuilder('foreman_tasks/tasks', '', task.id)}>
        {__('Click here to go to the tasks page for the task.')}
      </a>
    </span>
  );
};

export const saveUpstreamSubscriptions = (params, handleSuccess) =>
  APIActions.post({
    key: SAVE_UPSTREAM_SUBSCRIPTIONS_KEY,
    url: api.getApiUrl(`/organizations/${orgId()}/upstream_subscriptions`),
    params,
    successToast: saveSuccessToast,
    errorToast: error => getResponseErrorMsgs(error.response),
    handleSuccess,
  });

const pingUpstreamSubscriptions = () => dispatch =>
  dispatch(APIActions.get({
    key: PING_UPSTREAM_SUBSCRIPTIONS_KEY,
    url: api.getApiUrl(`/organizations/${orgId()}/upstream_subscriptions/ping`),
    handleSuccess: () => dispatch({ type: PING_UPSTREAM_SUBSCRIPTIONS_SUCCESS }),
    handleError: error => dispatch(apiError(PING_UPSTREAM_SUBSCRIPTIONS_FAILURE, error)),
  }));

export default pingUpstreamSubscriptions;
