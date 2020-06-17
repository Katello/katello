import { withRouter } from 'react-router-dom';
import ContentViewDetails from './ContentViewDetails';
import reducer from './ContentViewDetailReducer';

export const contentViewDetails = reducer;

export default withRouter(ContentViewDetails);
