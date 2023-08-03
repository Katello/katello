import { API_OPERATIONS, get, put } from 'foremanReact/redux/API';
import { foremanApi } from '../../../../../services/api';
import { HOST_ERRATA_KEY, HOST_ERRATA_APPLICABILITY_KEY } from './HostErrataConstants';
import { errorToast } from '../../../../../scenes/Tasks/helpers';

export const getInstallableErrata = (hostId, params) => get({
  type: API_OPERATIONS.GET,
  key: HOST_ERRATA_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/errata`),
  params,
});

export const regenerateApplicability = (hostId, params) => put({
  type: API_OPERATIONS.PUT,
  key: HOST_ERRATA_APPLICABILITY_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/errata/applicability`),
  // This endpoint doesn't return a task, so can't use renderTaskStartedToast
  // also can't use successToast because we want the type to be 'info'
  handleSuccess: () => {
    window.tfm.toastNotifications.notify({
      message: 'Regenerating errata applicability.',
      type: 'info',
      link: {
        children: 'View related tasks',
        href: '/foreman_tasks/tasks?search=action+~+applicability&page=1',
      },
    });
  },
  errorToast: error => errorToast(error),
  params,
});

