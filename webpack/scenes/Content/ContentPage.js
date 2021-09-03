import React, { useEffect, useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { Grid, GridItem, TextContent, Text, TextVariants } from '@patternfly/react-core';
import { isEmpty } from 'lodash';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import ContentTable from './Table/ContentTable';
import { selectContentTypes, selectContentTypesStatus } from './ContentSelectors';
import ContentConfig from './ContentConfig';
import { getContentTypes } from './ContentActions';
import Loading from '../../components/Loading';
import EmptyStateMessage from '../../components/Table/EmptyStateMessage';

const ContentPage = () => {
  const dispatch = useDispatch();
  const contentTypesResponse = useSelector(selectContentTypes);
  const contentTypesStatus = useSelector(selectContentTypesStatus);
  const [selectedContentType, setSelectedContentType] = useState(null);
  const [contentTypes, setContentTypes] = useState(null);

  useEffect(() => {
    // Set list of enabled content types and initial content type
    const buildContentTypes = () => {
      const types = {};
      contentTypesResponse.forEach((type) => {
        if (type.generic_browser) {
          const typeConfig = ContentConfig().find(config => config.names.singular === type.label);
          if (typeConfig) {
            const { names } = typeConfig;
            types[names.title] = [names.singular, names.plural];
          }
        }
      });
      return types;
    };

    if (contentTypesStatus === STATUS.RESOLVED) {
      const enabledContentTypes = buildContentTypes();
      setSelectedContentType(Object.keys(enabledContentTypes)[0]);
      setContentTypes(enabledContentTypes);
    }
  }, [contentTypesStatus, contentTypesResponse]);

  useEffect(() => {
    dispatch(getContentTypes());
  }, [dispatch]);

  if (contentTypesStatus === STATUS.PENDING) {
    return <Loading />;
  } else if (isEmpty(contentTypes)) {
    return (
      <EmptyStateMessage
        title="Browsable content types not found."
        body="No content types are enabled for this page."
      />
    );
  }

  return (
    <Grid className="grid-with-margin">
      <GridItem span={12}>
        <TextContent>
          <Text component={TextVariants.h1}>{__(`${selectedContentType}`)}</Text>
        </TextContent>
      </GridItem>
      <GridItem span={12}>
        <ContentTable {...{ selectedContentType, setSelectedContentType, contentTypes }} />
      </GridItem>
    </Grid>
  );
};

export default ContentPage;
