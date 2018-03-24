import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

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
export default connect(mapStateToProps, mapDispatchToProps)(UpstreamSubscriptionsPage);
