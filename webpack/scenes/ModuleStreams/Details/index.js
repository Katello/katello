import { bindActionCreators } from '@theforeman/vendor/redux';
import { connect } from '@theforeman/vendor/react-redux';
import { withRouter } from '@theforeman/vendor/react-router';
import reducer from './ModuleStreamDetailsReducer';
import * as moduleStreamDetailsActions from './ModuleStreamDetailsActions';
import ModuleStreamDetails from './ModuleStreamDetails';

const mapStateToProps = state => ({
  moduleStreamDetails: state.katello.moduleStreamDetails,
});

const actions = { ...moduleStreamDetailsActions };
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const moduleStreamDetails = reducer;

export default connect(mapStateToProps, mapDispatchToProps)(withRouter(ModuleStreamDetails));
