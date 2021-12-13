import React, { useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import {
  TextContent,
  TextList,
  TextListVariants,
  TextListItem,
  TextListItemVariants,
} from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';
import { selectContentDetails, selectContentDetailsStatus } from '../ContentSelectors';
import contentConfig from '../ContentConfig';
import { getContentDetails } from '../ContentActions';
import Loading from '../../../components/Loading';
/* eslint-disable react/no-array-index-key */
const ContentInfo = ({ contentType, id, tabKey }) => {
  const dispatch = useDispatch();
  const detailsResponse = useSelector(selectContentDetails);
  const detailsStatus = useSelector(selectContentDetailsStatus);

  const config = contentConfig().find(type => type.names.pluralLabel === contentType);
  const { columnHeaders } = config.tabs.find(header => header.tabKey === tabKey);

  useEffect(() => {
    if (!detailsResponse) {
      dispatch(getContentDetails(contentType, id));
    }
  });

  if (detailsStatus === STATUS.PENDING) {
    return <Loading />;
  }

  return (
    <TextContent className="margin-0-24">
      <TextList component={TextListVariants.dl}>
        {columnHeaders.map((col, index) => [
          <TextListItem
            key={`${index}_${col.title}`}
            component={TextListItemVariants.dt}
          > {col.title}
          </TextListItem>,
          <TextListItem
            key={index}
            component={TextListItemVariants.dd}
          > {col.getProperty(detailsResponse)}
          </TextListItem>])}
      </TextList>
    </TextContent>
  );
};

export default ContentInfo;

ContentInfo.propTypes = {
  contentType: PropTypes.string.isRequired,
  id: PropTypes.number.isRequired,
  tabKey: PropTypes.string.isRequired,
};
