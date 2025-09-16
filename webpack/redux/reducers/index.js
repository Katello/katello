import { combineReducers } from 'redux';
import { organization } from '../../containers/Application';
import redHatRepositories from './RedHatRepositories';
import { subscriptions } from '../../scenes/Subscriptions';
import { upstreamSubscriptions } from '../../scenes/Subscriptions/UpstreamSubscriptions';
import { manifestHistory } from '../../scenes/Subscriptions/Manifest';
import { subscriptionDetails } from '../../scenes/Subscriptions/Details';
import { setOrganization } from '../../components/SelectOrg/SetOrganization';
import { moduleStreams } from '../../scenes/ModuleStreams';
import { reducers as organizationProductsReducers } from '../OrganizationProducts';
import { moduleStreamDetails } from '../../scenes/ModuleStreams/Details';
import { contentViewDetails } from '../../scenes/ContentViews/Details';
import hostDetails from '../../components/extensions/HostDetails/HostDetailsReducer';
import searchBar from '../../components/extensions/SearchBar/SearchBarReducer';

export default combineReducers({
  organization,
  redHatRepositories,
  subscriptions,
  upstreamSubscriptions,
  manifestHistory,
  subscriptionDetails,
  setOrganization,
  moduleStreams,
  moduleStreamDetails,
  contentViewDetails,
  hostDetails,
  searchBar,
  ...organizationProductsReducers,
});
