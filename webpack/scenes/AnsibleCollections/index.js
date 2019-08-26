import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';

import AnsibleCollectionsPage from './AnsibleCollectionsPage';
import reducer from './AnsibleCollectionsReducer';
import * as AnsibleCollectionsActions from './AnsibleCollectionsActions';

const mapStateToProps = state => ({
  ansibleCollections: state.katello.ansibleCollections,
});

const mapDispatchToProps = dispatch => bindActionCreators(AnsibleCollectionsActions, dispatch);

export const ansibleCollections = reducer;

export default connect(mapStateToProps, mapDispatchToProps)(withRouter(AnsibleCollectionsPage));
