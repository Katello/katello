import React, { useState } from 'react';
import { FormattedMessage } from 'react-intl';
import {
  Alert,
  Grid,
  GridItem,
  CodeBlock,
  CodeBlockAction,
  CodeBlockCode,
  ClipboardCopyButton,
  ExpandableSection,
  ExpandableSectionToggle,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';

import { copyToClipboard } from '../helpers';

const ContentSourceTemplate = ({ template, hostCount }) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const [isCopied, setCopied] = useState(false);

  const handleCopy = (e) => {
    copyToClipboard(e, template);
    setCopied(true);
  };

  const actions = (
    <CodeBlockAction>
      <ClipboardCopyButton
        onClick={e => handleCopy(e)}
        exitDelay={600}
        maxWidth="110px"
        variant="plain"
      >
        {isCopied ? __('Copied to clipboard') : __('Copy to clipboard')}
      </ClipboardCopyButton>
    </CodeBlockAction>
  );

  return (
    <Grid>
      <GridItem span={7}>
        <Alert
          ouiaId="host-server-content-source-complete"
          variant="info"
          title={__('Configuration updated on Foreman')}
          className="margin-top-20"
          isInline
        />
        <Alert
          ouiaId="host-configuration-alert"
          variant="warning"
          title={
            <FormattedMessage
              defaultMessage={__('Configuration still must be updated on {hosts}')}
              values={{
                hosts: (
                  <FormattedMessage
                    defaultMessage="{count, plural, one {{singular}} other {# {plural}}}"
                    values={{
                      count: hostCount,
                      singular: __('the host'),
                      plural: __('hosts'),
                    }}
                    id="ccs-status-i18n"
                  />
                ),
              }}
              id="ccs-status-description-i18n"
            />
          }
          className="margin-top-20"
          isInline
        >
          <FormattedMessage
            defaultMessage={__('To finish the process of changing the content source, run the following script manually on {hosts}.')}
            values={{
              hosts: (
                <FormattedMessage
                  defaultMessage="{count, plural, one {{singular}} other {{plural}}}"
                  values={{
                    count: hostCount,
                    singular: __('the host'),
                    plural: __('the hosts'),
                  }}
                  id="ccs-status2-i18n"
                />
              ),
            }}
            id="ccs-status2-description-i18n"
          />
        </Alert>

      </GridItem>
      <GridItem span={7}>
        <CodeBlock actions={actions} className="cs_template_code margin-top-20">
          <CodeBlockCode>
            {__('Change content source')}
            <ExpandableSection contentId="code-block-expand-content" toggleId="code-block-expand-toggle" isExpanded={isExpanded} isDetached >
              {template}
            </ExpandableSection>
          </CodeBlockCode>
          <ExpandableSectionToggle
            isExpanded={isExpanded}
            onToggle={() => setIsExpanded(!isExpanded)}
            contentId="code-block-expand-content"
            toggleId="code-block-expand-toggle"
            direction="up"
          >
            {isExpanded ? 'Show less' : 'Show more'}
          </ExpandableSectionToggle>
        </CodeBlock>
      </GridItem>
    </Grid>);
};

ContentSourceTemplate.propTypes = {
  template: PropTypes.string,
  hostCount: PropTypes.number,
};

ContentSourceTemplate.defaultProps = {
  template: '',
  hostCount: 1,
};

export default ContentSourceTemplate;
