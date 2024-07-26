import { translate as __ } from 'foremanReact/common/I18n';
import { foremanUrl } from 'foremanReact/common/helpers';

const hostTableRowActions = (hostDetails) => {
  const hostIsRegistered = hostDetails?.subscription_facet_attributes?.uuid;
  return [
    {
      title: __('Change content view environments'),
      onClick: () => {
        window.location.href = foremanUrl(`hosts/${hostDetails.display_name}#/Overview?content_view_assignment=true`);
      },
      isDisabled: !hostIsRegistered,
    },
  ];
};

export default hostTableRowActions;
