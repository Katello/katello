import React from 'react';
import { useParams, useLocation } from 'react-router-dom';
import paramsFromHash from '../../../../utils/paramsFromHash';

const ContentViewFilterDetails = () => {
  const { id } = useParams();
  const { hash } = useLocation();
  const { params: { subContentId } } = paramsFromHash(hash);

  return (<>{`Showing the details for filter ${subContentId} for Content View ${id}`}</>);
};

export default ContentViewFilterDetails;
