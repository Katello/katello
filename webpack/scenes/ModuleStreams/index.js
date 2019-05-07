import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';

import ModuleStreamsPage from './ModuleStreamsPage';
import reducer from './ModuleStreamsReducer';
import * as ModuleStreamsActions from './ModuleStreamsActions';

const mapStateToProps = state => ({
  moduleStreams: state.katello.moduleStreams,
});

const mapDispatchToProps = dispatch => bindActionCreators(ModuleStreamsActions, dispatch);

export const moduleStreams = reducer;

export default connect(mapStateToProps, mapDispatchToProps)(withRouter(ModuleStreamsPage));
