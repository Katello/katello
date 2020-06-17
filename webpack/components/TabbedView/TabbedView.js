import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Page, Tabs, Tab, TabTitleText, PageSection, PageSectionVariants,
} from '@patternfly/react-core';

const TabbedView = ({ tabs }) => {
  const [activeTabKey, setActiveTabKey] = useState(0);
  const handleTabClick = (_event, tabIndex) => setActiveTabKey(tabIndex);

  return (
    <React.Fragment>
      <Tabs activeKey={activeTabKey} onSelect={handleTabClick}>
        {tabs.map((tab, i) => {
          const { title, content } = tab;
          return (
            <Tab
              aria-label={`${title} tab`}
              key={`${title}`}
              eventKey={i}
              title={<TabTitleText>{title}</TabTitleText>}
            >
              <Page>
                <PageSection variant={PageSectionVariants.light}>
                  {content}
                </PageSection>
              </Page>
            </Tab>
          );
        })}
      </Tabs>
    </React.Fragment>
  );
};

TabbedView.propTypes = {
  tabs: PropTypes.arrayOf(PropTypes.shape({
    title: PropTypes.string,
    content: PropTypes.element,
  })).isRequired,
};

export default TabbedView;
