import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as settingActions from 'foremanReact/components/Settings/SettingsActions';
import * as foremanModalActions from 'foremanReact/components/ForemanModal/ForemanModalActions';
import * as subscriptionActions from './SubscriptionActions';
import * as taskActions from '../Tasks/TaskActions';
import * as tableActions from '../Settings/Tables/TableActions';
import * as manifestActions from './Manifest/ManifestActions';

import {
  selectSubscriptionsState,
  selectSearchQuery,
  selectDeleteModalOpened,
  selectDeleteButtonDisabled,
  selectSubscriptionsTask,
  selectActivePermissions,
  selectIsTaskPending,
} from './SubscriptionsSelectors';
import { selectSettings,
  selectTableSettings } from '../../scenes/Settings/SettingsSelectors';
import { selectIsPollingTask } from '../Tasks/TaskSelectors';
import { selectSimpleContentAccessEnabled } from '../Organizations/OrganizationSelectors';

import reducer from './SubscriptionReducer';
import { SUBSCRIPTION_TABLE_NAME, SUBSCRIPTIONS } from './SubscriptionConstants';
import SubscriptionsPage from './SubscriptionsPage';

// map state to props
const mapStateToProps = (state) => {
  const subscriptions = selectSubscriptionsState(state);
  const subscriptionTableSettings = selectTableSettings(state, SUBSCRIPTION_TABLE_NAME);
  const settings = selectSettings(state);

  return {
    subscriptions,
    subscriptionTableSettings,
    settings,
    activePermissions: selectActivePermissions(state),
    simpleContentAccess: selectSimpleContentAccessEnabled(state),
    task: selectSubscriptionsTask(state),
    isTaskPending: selectIsTaskPending(state),
    isPollingTask: selectIsPollingTask(state, SUBSCRIPTIONS),
    searchQuery: selectSearchQuery(state),
    deleteModalOpened: selectDeleteModalOpened(state),
    deleteButtonDisabled: selectDeleteButtonDisabled(state),
    organization: state.katello.organization,
  };
};

// map action dispatchers to props
const actions = {
  ...subscriptionActions,
  ...taskActions,
  ...settingActions,
  ...tableActions,
  ...manifestActions,
  ...foremanModalActions,
};

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const subscriptions = reducer;

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(SubscriptionsPage);
