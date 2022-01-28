import React, { useEffect } from 'react';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';
import {
  shallowEqual,
  useDispatch,
  useSelector,
} from 'react-redux';
import Loading from '../../../components/Loading';
import EmptyStateMessage from '../../../components/Table/EmptyStateMessage';
import getContentViewDetails from './ContentViewDetailActions';
import {
  selectCVDetailError,
  selectCVDetailStatus,
} from './ContentViewDetailSelectors';

const DetailsContainer = ({ children, cvId }) => {
  const dispatch = useDispatch();
  const status = useSelector(state => selectCVDetailStatus(state, cvId), shallowEqual);
  const error = useSelector(state => selectCVDetailError(state, cvId), shallowEqual);

  useEffect(() => {
    dispatch(getContentViewDetails(cvId));
  }, [cvId, dispatch]);

  if (status === STATUS.PENDING) return (<Loading />);
  if (status === STATUS.ERROR) return (<EmptyStateMessage error={error} />);
  return (<>{children}</>);
};

DetailsContainer.propTypes = {
  children: PropTypes.element.isRequired,
  cvId: PropTypes.number.isRequired,
};

export default DetailsContainer;
