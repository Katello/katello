import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Link, useParams } from 'react-router-dom';
import {
  Grid,
  GridItem,
  TextContent,
  Text,
  TextVariants,
  Flex,
  Breadcrumb,
  BreadcrumbItem,
  DescriptionList,
  DescriptionListGroup,
  DescriptionListTerm,
  DescriptionListDescription,
} from '@patternfly/react-core';
import textStyles from '@patternfly/react-styles/css/utilities/Text/text';
import sizingStyles from '@patternfly/react-styles/css/utilities/Sizing/sizing';
import { useForemanPermissions } from 'foremanReact/Root/Context/ForemanContext';
import { STATUS } from 'foremanReact/constants';
import ContentConfig from '../ContentConfig';
import RoutedTabs from '../../../components/RoutedTabs';
import { selectContentDetails, selectContentDetailsStatus, selectContentDetailsError } from '../ContentSelectors';
import { getContentDetails } from '../ContentActions';
import Loading from '../../../components/Loading';
import EmptyStateMessage from '../../../components/Table/EmptyStateMessage';

const ContentDetails = () => {
  const dispatch = useDispatch();
  const permissions = useForemanPermissions();
  const contentDetailsResponse = useSelector(selectContentDetails);
  const contentDetailsResponseStatus = useSelector(selectContentDetailsStatus);
  const contentDetailsError = useSelector(selectContentDetailsError);

  const { id, content_type: contentType } = useParams();
  const contentId = Number(id);
  const config = ContentConfig.find(type =>
    type.names.pluralLabel === contentType);
  const { pluralTitle, pluralLabel } = config.names;
  const { headerFields = [] } = config;

  const tabs = [];
  config.tabs.forEach((tab) => {
    if (tab.permission && !permissions?.has(tab.permission)) return;
    tabs.push({
      title: tab.title,
      key: tab.tabKey,
      content: tab.getContent(contentType, contentId, tab.tabKey),
    });
  });

  useEffect(() => {
    dispatch(getContentDetails(contentType, contentId));
  }, [dispatch, contentType, contentId]);

  if (contentDetailsResponseStatus === STATUS.ERROR) {
    return <EmptyStateMessage error={contentDetailsError} />;
  }

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
            <TextContent className={sizingStyles.w_100}>
              <Text ouiaId="content-details-text" component={TextVariants.h1}>
                {contentDetailsResponse.name}
              </Text>
            </TextContent>
          </Flex>
          {headerFields.length > 0 && (
          <Grid hasGutter className="margin-top-16">
            {headerFields.map(field => (
              <GridItem key={field.title} span={12} md={field.md || 6}>
                <DescriptionList>
                  <DescriptionListGroup>
                    <DescriptionListTerm>{field.title}</DescriptionListTerm>
                    <DescriptionListDescription className={textStyles.textBreakWord}>
                      {field.getProperty(contentDetailsResponse)}
                    </DescriptionListDescription>
                  </DescriptionListGroup>
                </DescriptionList>
              </GridItem>
            ))}
          </Grid>
          )}
        </GridItem>
      </Grid>
      <GridItem span={12}>
        {tabs.length > 0 && (
          <RoutedTabs tabs={tabs} baseUrl={`/${contentType}/${contentId}`} defaultTabIndex={0} />
        )}
      </GridItem>
    </Grid >
  );
};
export default ContentDetails;
