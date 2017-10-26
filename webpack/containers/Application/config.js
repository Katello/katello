import Welcome from '../../scenes/Welcome';
import Dashboard from '../../scenes/Dashboard';
import Repos from '../../scenes/Repos';

export const links = [
  {
    text: 'Welcome',
    path: 'xui',
    component: Welcome,
  },
  {
    text: 'Dashboard',
    path: 'xui/dashboard',
    component: Dashboard,
  },
  {
    text: 'RH Repos',
    path: 'xui/repos',
    component: Repos,
  },
];
