import { combineReducers } from 'redux';
import redHatRepositories from './RedHatRepositories';
import { subscriptions } from '../../scenes/Subscriptions';
import { upstreamSubscriptions } from '../../scenes/Subscriptions/UpstreamSubscriptions';

export default combineReducers({
  redHatRepositories,
  subscriptions,
  upstreamSubscriptions,
});
