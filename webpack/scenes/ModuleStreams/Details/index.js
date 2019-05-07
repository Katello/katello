import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
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
