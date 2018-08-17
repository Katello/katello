import Repos from '../../scenes/RedHatRepositories';
import Subscriptions from '../../scenes/Subscriptions';
import UpstreamSubscriptions from '../../scenes/Subscriptions/UpstreamSubscriptions/index';
import SubscriptionDetails from '../../scenes/Subscriptions/Details';
import SetOrganization from '../../components/SelectOrg/SetOrganization';
import WithOrganization from '../../components/WithOrganization/withOrganization';
import ModuleStreams from '../../scenes/ModuleStreams';

// eslint-disable-next-line import/prefer-default-export
export const links = [
  {
    text: __('RH Repos'),
    path: 'redhat_repositories',
    component: WithOrganization(Repos, '/redhat_repositories'),
  },
  {
    text: __('RH Subscriptions'),
    path: 'subscriptions',
    component: WithOrganization(Subscriptions, '/subscriptions'),
  },
  {
    text: __('Add Subscriptions'),
    path: 'subscriptions/add',
    component: UpstreamSubscriptions,
  },
  {
    text: __('Subscription Details'),
    // eslint-disable-next-line no-useless-escape
    path: 'subscriptions/:id(\[0-9]*$\)',
    component: SubscriptionDetails,
  },
  {
    text: __('Select Organization'),
    path: 'organization_select',
    component: SetOrganization,
  },
  {
    text: 'Module Streams',
    path: 'module_streams',
    component: ModuleStreams,
  },
];
