import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as subscriptionActions from './SubscriptionActions';
import * as taskActions from '../Tasks/TaskActions';

import reducer from './SubscriptionReducer';

import SubscriptionsPage from './SubscriptionsPage';

// map state to props
const mapStateToProps = state => ({
  subscriptions: state.katello.subscriptions,
  tasks: state.katello.subscriptions.tasks,
});

// map action dispatchers to props
const actions = { ...subscriptionActions, ...taskActions };
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const subscriptions = reducer;

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(SubscriptionsPage);
