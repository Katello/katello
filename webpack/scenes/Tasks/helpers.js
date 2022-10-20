import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import store from 'foremanReact/redux';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { addToast } from 'foremanReact/components/ToastsList/slice.js';
import { getResponseErrorMsgs } from '../../utils/helpers';

export const bulkSearchKey = key => `${key}_TASK_SEARCH`;
export const pollTaskKey = key => `${key}_POLL_TASK`;

const link = ({ id, message, baseUrl }) => ({
  children: message,
  href: urlBuilder(baseUrl, '', id),
});

const getErrors = task => (
  <ul>
    {task.humanized.errors.map(e => (
      <li key={e}> {e} </li>
    ))}
  </ul>
);

const foremanTasksLink = id => link({
  id,
  message: __('Go to task page'),
  baseUrl: 'foreman_tasks/tasks',
});

const rexJobLink = id => link({
  id,
  message: __('Go to job details'),
  baseUrl: 'job_invocations',
});

export const renderTaskStartedToast = (task, override = '') => {
  if (!task) return;

  const message = (__(`Task ${task.humanized.action} has started.`));

  if (override) {
    window.tfm.toastNotifications.notify({
      message: override,
      type: 'info',
      link: foremanTasksLink(task.id),
    });
  } else {
    window.tfm.toastNotifications.notify({
      message,
      type: 'info',
      link: foremanTasksLink(task.id),
    });
  }
};

export const renderRexJobStartedToast = ({ id, description, key }) => {
  if (!id) return;
  const message = (__(`Job '${description}' has started.`));

  store.dispatch(addToast({
    message,
    type: 'info',
    link: rexJobLink(id),
    sticky: true,
    key,
  }));
};

export const renderRexJobFailedToast = ({ id, description }) => {
  if (!id) return;

  const message = (__(`Remote execution job '${description}' failed.`));

  window.tfm.toastNotifications.notify({
    message,
    type: 'danger',
    link: rexJobLink(id),
  });
};

export const renderRexJobSucceededToast = ({ id, description }) => {
  if (!id) return;

  const message = (__(`Job '${description}' completed`));

  window.tfm.toastNotifications.notify({
    message,
    type: 'success',
    link: rexJobLink(id),
  });
};

export const taskFinishedToast = (task) => {
  const message = __(`Task ${task.humanized.action} completed with a result of ${task.result}.
  ${task.errors ? getErrors(task) : ''}`);

  return {
    message,
    type: task.result,
    link: foremanTasksLink(task.id),
  };
};

export const renderTaskFinishedToast = (task) => {
  if (!task) return;

  window.tfm.toastNotifications.notify(taskFinishedToast(task));
};

export const errorToast = error => getResponseErrorMsgs(error.response);
