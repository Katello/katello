import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { withRouter } from 'react-router';
import reducer from './SubscriptionDetailReducer';
import { loadProducts } from '../../Products/ProductActions';
import * as subscriptionDetailActions from './SubscriptionDetailActions';
import SubscriptionDetails from './SubscriptionDetails';

// map state to props
const mapStateToProps = state => ({
  subscriptionDetails: state.katello.subscriptionDetails,
});

// map action dispatchers to props
const actions = { ...subscriptionDetailActions, loadProducts };
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const subscriptionDetails = reducer;

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(withRouter(SubscriptionDetails));
