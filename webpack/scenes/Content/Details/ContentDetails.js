import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Link, useParams } from 'react-router-dom';
import { Grid, GridItem, TextContent, Text, TextVariants, Flex, Breadcrumb, BreadcrumbItem } from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';
import ContentConfig from '../ContentConfig';
import RoutedTabs from '../../../components/RoutedTabs';
import { selectContentDetails, selectContentDetailsStatus } from '../ContentSelectors';
import { getContentDetails } from '../ContentActions';
import Loading from '../../../components/Loading';

const ContentDetails = () => {
  const dispatch = useDispatch();
  const contentDetailsResponse = useSelector(selectContentDetails);
  const contentDetailsResponseStatus = useSelector(selectContentDetailsStatus);

  const { id, content_type: contentType } = useParams();
  const contentId = Number(id);
  const config = ContentConfig.find(type =>
    type.names.pluralLabel === contentType);
  const { pluralTitle, pluralLabel } = config.names;

  const tabs = [];
  config.tabs.forEach((tab) => {
    tabs.push({
      title: tab.title,
      key: tab.tabKey,
      content: tab.getContent(contentType, contentId, tab.tabKey),
    });
  });

  useEffect(() => {
    dispatch(getContentDetails(contentType, contentId));
  }, [dispatch, contentType, contentId]);

  if (contentDetailsResponseStatus === STATUS.PENDING) {
    return <Loading />;
  }

  return (
    <Grid>
      <Grid className="margin-16-24">
        <Breadcrumb ouiaId="content-details-breadcrumb">
          <BreadcrumbItem
            aria-label="content_breadcrumb"
            render={() => (<Link to={`/content/${pluralLabel}`}>{pluralTitle}</Link>)}
          />
          <BreadcrumbItem
            aria-label="content_breadcrumb_content"
            isActive
          > {contentDetailsResponse.name}
          </BreadcrumbItem>
        </Breadcrumb>
        <GridItem span={12} className="margin-top-24">
          <Flex>
            <TextContent>
              <Text ouiaId="content-details-text" component={TextVariants.h1}>
                {contentDetailsResponse.name}
              </Text>
            </TextContent>
          </Flex>
        </GridItem>
      </Grid>
      <GridItem span={12}>
        <RoutedTabs tabs={tabs} baseUrl={`/${contentType}/${contentId}`} defaultTabIndex={0} />
      </GridItem>
    </Grid >
  );
};
export default ContentDetails;
