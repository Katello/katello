import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import helpers from '../../move_to_foreman/common/helpers';
import { notify } from '../../move_to_foreman/foreman_toast_notifications';

const link = id => ({
  children: __('Go to task page'),
  href: helpers.urlBuilder('foreman_tasks/tasks', '', id),
});
const getErrors = task => (
  <ul>
    {task.humanized.errors.map(error => (
      <li key={error}> {error} </li>
        ))}
  </ul>
);

export const renderTaskStartedToast = (task) => {
  if (!task) return;

  const message = (__(`Task ${task.humanized.action} has started.`));

  notify({
    message,
    type: 'info',
    link: link(task.id),

  });
};

export const renderTaskFinishedToast = (task) => {
  if (!task) return;

  const message = __(`Task ${task.action} completed with a result of ${task.result}.
  ${task.errors ? getErrors(task) : ''}`);

  notify({
    message,
    type: task.result,
    link: link(task.id),
  });
};
