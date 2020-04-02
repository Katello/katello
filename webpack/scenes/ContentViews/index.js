import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';

import ContentViewsPage from './ContentViewsPage';
import * as ContentViewsActions from './ContentViewsActions';
import reducer from './ContentViewsReducer';

const mapStateToProps = (state) => {
  const cvState = state.katello.contentViews;
  return { ...cvState };
};

const mapDispatchToProps = dispatch => bindActionCreators(ContentViewsActions, dispatch);

export const contentViews = reducer;

export default connect(mapStateToProps, mapDispatchToProps)(withRouter(ContentViewsPage));
