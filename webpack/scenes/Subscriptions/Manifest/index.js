import { bindActionCreators } from 'redux';

import { connect } from 'react-redux';

import * as manifestActions from './ManifestActions';
import * as organizationActions from '../../Organizations/OrganizationActions';
import * as subscriptionsActions from '../SubscriptionActions';
import history from './ManifestHistoryReducer';

import ManifestModal from './ManageManifestModal';

import './Manifest.scss';

// map state to props
const mapStateToProps = state => ({
  organization: state.katello.organization,
  manifestHistory: state.katello.manifestHistory,
  taskDetails: state.katello.manifestHistory.taskDetails,
});

// map action dispatchers to props
const actions = {
  ...manifestActions, ...organizationActions, ...subscriptionsActions,
};
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const manifestHistory = history;

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(ManifestModal);
