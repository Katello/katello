import { bindActionCreators } from '@theforeman/vendor/redux';
import { connect } from '@theforeman/vendor/react-redux';
import { withRouter } from '@theforeman/vendor/react-router';

import ModuleStreamsPage from './ModuleStreamsPage';
import reducer from './ModuleStreamsReducer';
import * as ModuleStreamsActions from './ModuleStreamsActions';

const mapStateToProps = state => ({
  moduleStreams: state.katello.moduleStreams,
});

const mapDispatchToProps = dispatch => bindActionCreators(ModuleStreamsActions, dispatch);

export const moduleStreams = reducer;

export default connect(mapStateToProps, mapDispatchToProps)(withRouter(ModuleStreamsPage));
