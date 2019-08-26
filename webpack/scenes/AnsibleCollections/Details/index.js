import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import reducer from './AnsibleCollectionDetailsReducer';
import * as ansibleCollectionDetailsActions from './AnsibleCollectionDetailsActions';
import AnsibleCollectionDetails from './AnsibleCollectionDetails';

const mapStateToProps = state => ({
  ansibleCollectionDetails: state.katello.ansibleCollectionDetails,
});

const actions = { ...ansibleCollectionDetailsActions };
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const ansibleCollectionDetails = reducer;

export default connect(mapStateToProps, mapDispatchToProps)(withRouter(AnsibleCollectionDetails));
