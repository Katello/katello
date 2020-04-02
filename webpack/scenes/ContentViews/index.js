import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';

import ContentViewPage from './ContentViewPage';
import * as ContentViewActions from './ContentViewActions';
import reducer from './ContentViewReducer';

const mapStateToProps = (state) => ({
  contentViews: state.katello.contentViews.index ,
});

const mapDispatchToProps = dispatch => bindActionCreators(ContentViewActions, dispatch);

export const contentViews = reducer;

export default connect(mapStateToProps, mapDispatchToProps)(withRouter(ContentViewPage));
