import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as actions from './SubscriptionActions';
import reducer from './SubscriptionReducer';

import SubscriptionsPage from './SubscriptionsPage';

// map state to props
const mapStateToProps = state => ({ subscriptions: state.katello.subscriptions });

// map action dispatchers to props
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const subscriptions = reducer;

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(SubscriptionsPage);
