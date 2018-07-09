import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import PackagesPage from './PackagesPage';
import reducer from './PackagesReducer';
import * as packagesActions from './PackagesActions';

// map state to props
const mapStateToProps = state => ({
  packages: state.katello.packages,
});

// map action dispatchers to props
const mapDispatchToProps = dispatch => bindActionCreators(packagesActions, dispatch);

export const packages = reducer;

export default connect(mapStateToProps, mapDispatchToProps)(PackagesPage);
