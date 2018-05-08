import { combineReducers } from 'redux';
import { organization } from '../../containers/Application';
import redHatRepositories from './RedHatRepositories';
import { subscriptions } from '../../scenes/Subscriptions';
import { upstreamSubscriptions } from '../../scenes/Subscriptions/UpstreamSubscriptions';
import { manifestHistory } from '../../scenes/Subscriptions/Manifest';

export default combineReducers({
  organization,
  redHatRepositories,
  subscriptions,
  upstreamSubscriptions,
  manifestHistory,
});
