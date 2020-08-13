import { bindActionCreators } from 'redux';

import { connect } from 'react-redux';
import * as foremanModalActions from 'foremanReact/components/ForemanModal/ForemanModalActions';
import * as manifestActions from './ManifestActions';
import * as organizationActions from '../../Organizations/OrganizationActions';
import * as tasksActions from '../../Tasks/TaskActions';
import history from './ManifestHistoryReducer';
import { selectSimpleContentAccessEnabled, selectIsManifestImported } from '../../Organizations/OrganizationSelectors';
import { selectManifestActionStarted } from '../SubscriptionsSelectors';

import ManifestModal from './ManageManifestModal';

import './Manifest.scss';

// map state to props
const mapStateToProps = state => ({
  organization: state.katello.organization,
  manifestHistory: state.katello.manifestHistory,
  simpleContentAccess: selectSimpleContentAccessEnabled(state),
  isManifestImported: selectIsManifestImported(state),
  modalOpenState: state.foremanModals.ManageManifestModal,
  manifestActionStarted: selectManifestActionStarted(state),
});

// map action dispatchers to props
const actions = {
  ...manifestActions, ...organizationActions, ...tasksActions, ...foremanModalActions,
};
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const manifestHistory = history;

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(ManifestModal);
