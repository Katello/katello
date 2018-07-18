import { combineReducers } from 'redux';
import { organization } from '../../containers/Application';
import redHatRepositories from './RedHatRepositories';
import { reducers as subscriptionsReducers } from '../../scenes/Subscriptions';
import { reducers as tasksMonitorReducers } from '../../scenes/TasksMonitor';
import { upstreamSubscriptions } from '../../scenes/Subscriptions/UpstreamSubscriptions';
import { manifestHistory } from '../../scenes/Subscriptions/Manifest';
import { subscriptionDetails } from '../../scenes/Subscriptions/Details';
import { setOrganization } from '../../components/SelectOrg/SetOrganization';

export default combineReducers({
  organization,
  redHatRepositories,
  upstreamSubscriptions,
  manifestHistory,
  subscriptionDetails,
  setOrganization,
  ...subscriptionsReducers,
  ...tasksMonitorReducers,
});
