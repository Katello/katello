import { connect } from 'react-redux';
import * as actions from './SystemStatusesActions';
import { selectAllServices, selectStatus } from './SystemStatusesSelectors';
import reducer from './SystemStatusesReducer';

import SystemStatuses from './SystemStatuses';

const mapStateToProps = ({ katelloExtends }) => ({
  services: selectAllServices(katelloExtends),
  status: selectStatus(katelloExtends),
});

// export reducers
export const reducers = { systemServices: reducer };

export default connect(
  mapStateToProps,
  actions,
)(SystemStatuses);
