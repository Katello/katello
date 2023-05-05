import React, { useEffect, useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { useParams } from 'react-router-dom';
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

const GenericContentPage = () => {
  const dispatch = useDispatch();
  const contentTypesResponse = useSelector(selectContentTypes);
  const contentTypesStatus = useSelector(selectContentTypesStatus);
  const [selectedContentType, setSelectedContentType] = useState(null);
  const [showContentTypeSelector, setShowContentTypeSelector] = useState(true);
  const [contentTypes, setContentTypes] = useState(null);
  const { content_type: contentType } = useParams();

  useEffect(() => {
    // Set list of enabled content types and initial content type
    const buildContentTypes = () => {
      const types = {};
      contentTypesResponse.forEach((type) => {
        if (type.generic_browser) {
          const typeConfig = ContentConfig.find(config =>
            config.names.singularLabel === type.label);
          if (typeConfig) {
            const { names } = typeConfig;
            types[names.pluralTitle] = [names.singularLabel, names.pluralLabel];
          }
        }
      });
      return types;
    };

    if (contentTypesStatus === STATUS.RESOLVED) {
      const enabledContentTypes = buildContentTypes();
      if (!contentType) {
        setSelectedContentType(Object.keys(enabledContentTypes)[0]);
      } else {
        Object.entries(enabledContentTypes).forEach(([key, value]) => {
          if (value.includes(contentType)) {
            setSelectedContentType(key);
            setShowContentTypeSelector(false);
          }
        });
      }
      setContentTypes(enabledContentTypes);
    }
  }, [contentTypesStatus, contentTypesResponse, contentType]);

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
    <Grid>
      <GridItem span={12} className="margin-24">
        <TextContent>
          <Text ouiaId="page-text" component={TextVariants.h1}>{__(`${selectedContentType}`)}</Text>
        </TextContent>
      </GridItem>
      <GridItem span={12}>
        <ContentTable {...{
          selectedContentType, setSelectedContentType, contentTypes, showContentTypeSelector,
        }}
        />
      </GridItem>
    </Grid>
  );
};

export default GenericContentPage;
