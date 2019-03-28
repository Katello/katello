import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import * as settingActions from 'foremanReact/components/Settings/SettingsActions';

import * as subscriptionActions from './SubscriptionActions';
import * as taskActions from '../Tasks/TaskActions';
import * as tableActions from '../Settings/Tables/TableActions';
import * as manifestActions from './Manifest/ManifestActions';

import {
  selectSubscriptionsState,
  selectSearchQuery,
  selectManifestModalOpened,
  selectDeleteModalOpened,
  selectTaskModalOpened,
  selectDeleteButtonDisabled,
  selectSubscriptionsTasks,
  selectTableSettings,
} from './SubscriptionsSelectors';

import reducer from './SubscriptionReducer';
import { SUBSCRIPTION_TABLE_NAME } from './SubscriptionConstants';
import SubscriptionsPage from './SubscriptionsPage';

// map state to props
const mapStateToProps = (state) => {
  const subscriptions = selectSubscriptionsState(state);
  const subscriptionTableSettings = selectTableSettings(state, SUBSCRIPTION_TABLE_NAME);

  return {
    subscriptions,
    subscriptionTableSettings,
    tasks: selectSubscriptionsTasks(state),
    searchQuery: selectSearchQuery(state),
    manifestModalOpened: selectManifestModalOpened(state),
    deleteModalOpened: selectDeleteModalOpened(state),
    taskModalOpened: selectTaskModalOpened(state),
    deleteButtonDisabled: selectDeleteButtonDisabled(state),
    organization: state.katello.organization,
    taskDetails: state.katello.manifestHistory.taskDetails,
  };
};

// map action dispatchers to props
const actions = {
  ...subscriptionActions,
  ...taskActions,
  ...settingActions,
  ...tableActions,
  ...manifestActions,
};

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const subscriptions = reducer;

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(withRouter(SubscriptionsPage));
