import { bindActionCreators } from '@theforeman/vendor/redux';
import { connect } from '@theforeman/vendor/react-redux';
import { withRouter } from '@theforeman/vendor/react-router';

import * as actions from './UpstreamSubscriptionsActions';
import reducer from './UpstreamSubscriptionsReducer';

import UpstreamSubscriptionsPage from './UpstreamSubscriptionsPage';

// map state to props
const mapStateToProps = state => ({ upstreamSubscriptions: state.katello.upstreamSubscriptions });

// map action dispatchers to props
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const upstreamSubscriptions = reducer;

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(withRouter(UpstreamSubscriptionsPage));
