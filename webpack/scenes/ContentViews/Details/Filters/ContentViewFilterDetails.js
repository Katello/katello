import React from 'react';
import { useParams } from 'react-router-dom';

const ContentViewFilterDetails = () => {
  const { id, subContentId } = useParams();
  return (<>{`Showing the details for filter ${subContentId} for Content View ${id}`}</>);

}

export default ContentViewFilterDetails;