import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as subscriptionActions from './SubscriptionActions';
import * as taskActions from '../Tasks/TaskActions';
import * as manifestAction from '../Subscriptions/Manifest/ManifestActions';
import * as settingActions from '../../move_to_foreman/Settings/SettingsActions';

import reducer from './SubscriptionReducer';

import SubscriptionsPage from './SubscriptionsPage';

// map state to props
const mapStateToProps = state => ({
  organization: state.katello.organization,
  subscriptions: state.katello.subscriptions,
  tasks: state.katello.subscriptions.tasks,
  activeTaskOrg: state.katello.manifestHistory.activeTaskOrg,
  activeOrgName: state.katello.manifestHistory.activeOrgName,
});

// map action dispatchers to props
const actions = {
  ...subscriptionActions, ...taskActions, ...settingActions, ...manifestAction,
};
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const subscriptions = reducer;

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(SubscriptionsPage);
