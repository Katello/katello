import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as subscriptionActions from './SubscriptionActions';
import * as taskActions from '../Tasks/TaskActions';
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
import { selectIsPollingTask } from '../Tasks/TaskSelectors';
import { selectOrganizationState, selectIsManifestImported } from '../Organizations/OrganizationSelectors';
import { pingUpstreamSubscriptions } from './UpstreamSubscriptions/UpstreamSubscriptionsActions';
import reducer from './SubscriptionReducer';
import { SUBSCRIPTIONS } from './SubscriptionConstants';
import SubscriptionsPage from './SubscriptionsPage';

// map state to props
const mapStateToProps = (state) => {
  const subscriptions = selectSubscriptionsState(state);

  return {
    subscriptions,
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
  ...manifestActions,
};

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const subscriptions = reducer;

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(SubscriptionsPage);
