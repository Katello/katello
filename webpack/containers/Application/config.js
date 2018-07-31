import Repos from '../../scenes/RedHatRepositories';
import Subscriptions from '../../scenes/Subscriptions';
import UpstreamSubscriptions from '../../scenes/Subscriptions/UpstreamSubscriptions/index';
import SubscriptionDetails from '../../scenes/Subscriptions/Details';
import SetOrganization from '../../components/SelectOrg/SetOrganization';
import WithOrganization from '../../components/WithOrganization/withOrganization';

// eslint-disable-next-line import/prefer-default-export
export const links = [
  {
    text: 'RH Repos',
    path: 'redhat_repositories',
    component: WithOrganization(Repos, '/redhat_repositories'),
  },
  {
    text: 'RH Subscriptions',
    path: 'subscriptions',
    component: WithOrganization(Subscriptions, '/subscriptions'),
  },
  {
    path: 'subscriptions/add',
    component: UpstreamSubscriptions,
  },
  {
    // eslint-disable-next-line no-useless-escape
    path: 'subscriptions/:id(\[0-9]*$\)',
    component: SubscriptionDetails,
  },
  {
    path: 'organization_select',
    component: SetOrganization,
  },
];
