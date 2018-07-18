import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as subscriptionActions from './SubscriptionActions';
import * as settingActions from '../../move_to_foreman/Settings/SettingsActions';

import {
  selectSubscriptionsState,
  selectManifestActionsDisabled,
  selectManifestActionsDisabledReason,
  selectDeleteButtonDisabledReason,
  selectMonitorCurrentTask,
  selectHasMonitorTasksInProgress,
} from './SubscriptionsSelectors';

import reducer from './SubscriptionReducer';

import SubscriptionsPage from './SubscriptionsPage';

// map state to props
const mapStateToProps = (state) => {
  const subscriptions = selectSubscriptionsState(state);

  return {
    subscriptions,
    manifestModalOpened: subscriptions.manifestModalOpened,
    deleteModalOpened: subscriptions.deleteModalOpened,
    deleteButtonDisabled: subscriptions.deleteButtonDisabled,
    manifestActionsDisabled: selectManifestActionsDisabled(state),
    manifestActionsDisabledReason: selectManifestActionsDisabledReason(state),
    deleteButtonDisabledReason: selectDeleteButtonDisabledReason(state),
    currentManifestTask: selectMonitorCurrentTask(state),
    hasTaskInProgress: selectHasMonitorTasksInProgress(state),
  };
};

// map action dispatchers to props
const actions = { ...subscriptionActions, ...settingActions };
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const reducers = { subscriptions: reducer };

// export connected component
export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(SubscriptionsPage);
