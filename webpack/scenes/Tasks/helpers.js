import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
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

export const renderTaskStartedToast = (task) => {
  if (!task) return;

  const message = (__(`Task ${task.humanized.action} has started.`));

  window.tfm.toastNotifications.notify({
    message,
    type: 'info',
    link: foremanTasksLink(task.id),

  });
};

export const renderRexJobStartedToast = ({ id, description }) => {
  if (!id) return;

  const message = (__(`Job ${description} has started.`));

  window.tfm.toastNotifications.notify({
    message,
    type: 'info',
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
