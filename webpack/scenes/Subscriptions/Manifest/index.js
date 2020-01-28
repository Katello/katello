import { bindActionCreators } from 'redux';

import { connect } from 'react-redux';
import * as foremanModalActions from 'foremanReact/components/ForemanModal/ForemanModalActions';
import { selectIsModalOpen } from 'foremanReact/components/ForemanModal/ForemanModalSelectors';
import { DELETE_MANIFEST_MODAL_ID } from './ManifestConstants';

import * as manifestActions from './ManifestActions';
import * as organizationActions from '../../Organizations/OrganizationActions';
import * as tasksActions from '../../Tasks/TaskActions';
import history from './ManifestHistoryReducer';
import { selectSimpleContentAccessEnabled } from '../../Organizations/OrganizationSelectors';

import ManifestModal from './ManageManifestModal';

import './Manifest.scss';

// map state to props
const mapStateToProps = state => ({
  organization: state.katello.organization,
  manifestHistory: state.katello.manifestHistory,
  taskDetails: state.katello.manifestHistory.taskDetails,
  simpleContentAccess: selectSimpleContentAccessEnabled(state),
  modalOpenState: state.foremanModals.ManageManifestModal,
  deleteManifestModalIsOpen: selectIsModalOpen(state, DELETE_MANIFEST_MODAL_ID),
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
