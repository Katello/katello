import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as subscriptionActions from './SubscriptionActions';
import * as taskActions from '../Tasks/TaskActions';
import * as tableActions from '../Settings/Tables/TableActions';
import * as manifestActions from './Manifest/ManifestActions';

import {
  selectSubscriptionsState,
  selectSearchQuery,
  selectDeleteButtonDisabled,
  selectSubscriptionsTask,
  selectActivePermissions,
  selectIsTaskPending,
  selectHasUpstreamConnection,
  selectDeleteModalOpened,
} from './SubscriptionsSelectors';
import selectTableSettings from '../../scenes/Settings/SettingsSelectors';
import { selectIsPollingTask } from '../Tasks/TaskSelectors';
import { selectOrganizationState, selectIsManifestImported } from '../Organizations/OrganizationSelectors';
import { pingUpstreamSubscriptions } from './UpstreamSubscriptions/UpstreamSubscriptionsActions';
import reducer from './SubscriptionReducer';
import { SUBSCRIPTION_TABLE_NAME, SUBSCRIPTIONS } from './SubscriptionConstants';
import SubscriptionsPage from './SubscriptionsPage';

// map state to props
const mapStateToProps = (state) => {
  const subscriptions = selectSubscriptionsState(state);
  const subscriptionTableSettings = selectTableSettings(state, SUBSCRIPTION_TABLE_NAME);

  return {
    subscriptions,
    subscriptionTableSettings,
    activePermissions: selectActivePermissions(state),
    isManifestImported: selectIsManifestImported(state),
    hasUpstreamConnection: selectHasUpstreamConnection(state),
    task: selectSubscriptionsTask(state),
    isTaskPending: selectIsTaskPending(state),
    isPollingTask: selectIsPollingTask(state, SUBSCRIPTIONS),
    searchQuery: selectSearchQuery(state),
    deleteModalOpened: selectDeleteModalOpened(state),
    deleteButtonDisabled: selectDeleteButtonDisabled(state),
    organization: selectOrganizationState(state),
  };
};

// map action dispatchers to props
const actions = {
  pingUpstreamSubscriptions,
  ...subscriptionActions,
  ...taskActions,
  ...tableActions,
  ...manifestActions,
};

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const subscriptions = reducer;

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(SubscriptionsPage);
