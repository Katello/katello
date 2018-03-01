import Welcome from '../../scenes/Welcome';
import Repos from '../../scenes/RedHatRepositories';
import Subscriptions from '../../scenes/Subscriptions';


// eslint-disable-next-line import/prefer-default-export
export const links = [
  {
    text: 'Welcome',
    path: 'xui',
    component: Welcome,
  },
  {
    text: 'RH Repos',
    path: 'xui/repos',
    component: Repos,
  },
  {
    text: 'RH Subscriptions',
    path: 'xui/subscriptions',
    component: Subscriptions,
  },
];
