// Import necessary modules and components from react, react-redux, and @patternfly/react-core libraries
import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useParams } from 'react-router-dom';
import {
  Flex,
  FlexItem,
  TextContent,
  TextList,
  TextListVariants,
  TextListItem,
  TextListItemVariants,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import {selectFlatpakRemoteDetails} from "./FlatpakRemoteSelectors";
import {getFlatpakRemoteInfo} from "./FlatpakRemoteActions";

const FlatpakRemoteInfo = () => {
  const remoteId = Number(useParams().id);

  // Utilize useSelector hook to select details from the state
  const details = useSelector((state) =>
    selectFlatpakRemoteDetails(state, remoteId) || {}
  );
  const dispatch = useDispatch();
  useEffect(() => {
    dispatch(getFlatpakRemoteInfo(remoteId));
  }, [remoteId, dispatch]);


  // Return the component's UI structure using PatternFly components
  return (
    <TextContent className="margin-0-24">
      <TextList component={TextListVariants.dl}>
        {/* Wrap FlexItems inside a Flex container */}
        <Flex>
          <FlexItem spacer={{ default: 'spacerXs' }}>
            <TextListItem component={TextListItemVariants.dt}>
              {__('Name')}
            </TextListItem>
            <TextListItem
              aria-label="name text value"
              component={TextListItemVariants.dd}
              className="foreman-spaced-list"
            >
              {details.name || __('No Name Found')}
            </TextListItem>
          </FlexItem>
          <FlexItem spacer={{ default: 'spacerXs' }}>
            <TextListItem component={TextListItemVariants.dt}>
              {__('URL')}
            </TextListItem>
            <TextListItem
              aria-label="url text value"
              component={TextListItemVariants.dd}
              className="foreman-spaced-list"
            >
              {details.url || __('No URL Found')}
            </TextListItem>
          </FlexItem>
        </Flex>
      </TextList>
    </TextContent>
  );
};

// Export the FlatpakRemoteInfo component to be used in your application
export default FlatpakRemoteInfo;