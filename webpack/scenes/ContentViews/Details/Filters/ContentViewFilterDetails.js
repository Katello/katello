import React from 'react';
import qs from 'query-string';
import { useParams, useLocation } from 'react-router-dom';

const ContentViewFilterDetails = () => {
  const { id } = useParams();
  // should move to custom hook for hash and query params if we go with this approach
  const { hash = '' } = useLocation();
  const [_, queryParams = {}] = hash.split('?');
  const { subContentId } = qs.parse(queryParams);

  return (<>{`Showing the details for filter ${subContentId} for Content View ${id}`}</>);
};

export default ContentViewFilterDetails;
