import Repos from '../../scenes/RedHatRepositories';
import Subscriptions from '../../scenes/Subscriptions';
import UpstreamSubscriptions from '../../scenes/Subscriptions/UpstreamSubscriptions/index';
import SubscriptionDetails from '../../scenes/Subscriptions/Details';

// eslint-disable-next-line import/prefer-default-export
export const links = [
  {
    text: 'RH Repos',
    path: 'redhat_repositories',
    component: Repos,
  },
  {
    text: 'RH Subscriptions',
    path: 'subscriptions',
    component: Subscriptions,
  },
  {
    path: 'subscriptions/add',
    component: UpstreamSubscriptions,
  },
  {
    path: 'subscriptions/:id(\[0-9]*$\)',
    component: SubscriptionDetails,
  },
];
