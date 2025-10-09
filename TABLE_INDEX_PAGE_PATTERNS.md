# Foreman React Patterns Guide

This document outlines the key patterns used in Foreman React components, particularly for table-based interfaces and API integration.

## TableIndexPage Component

TableIndexPage is Foreman's standardized component for creating table-based list pages with built-in search, pagination, sorting, and bulk actions.

### Two Usage Patterns

#### Pattern 1: Declarative/Simple (Recommended for most cases)

**When to use**: Standard CRUD operations, simple table rendering
**Example**: ModelsPage, SyncManagementPage

```javascript
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';

const MyPage = () => {
  const columns = {
    name: {
      title: __('Name'),
      wrapper: ({ can_edit: canEdit, id, name }) =>
        canEdit ? (
          <a href={`/models/${id}/edit`}>{name}</a>
        ) : (
          <span>{name}</span>
        ),
      isSorted: true,
    },
    description: {
      title: __('Description'),
    },
  };

  const customActionButtons = [
    {
      title: __('Custom Action'),
      action: { onClick: handleCustomAction },
    },
  ];

  return (
    <TableIndexPage
      apiUrl="/api/v2/my_resources"
      apiOptions={{ key: 'MY_RESOURCES_KEY' }}
      header={__('My Resources')}
      controller="my_resources"
      columns={columns}
      customActionButtons={customActionButtons}
      searchable={true}
      creatable={true}
      isDeleteable={true}
      showCheckboxes={true}
    />
  );
};
```

**Key characteristics**:
- Pass `columns` prop with column definitions
- No children component
- TableIndexPage handles all table rendering internally
- Clean and simple for standard use cases

#### Pattern 2: Composable/Custom (For complex requirements)

**When to use**: Complex row rendering, custom selection logic, special interactions
**Example**: HostsIndex

```javascript
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import { Table } from 'foremanReact/components/PF4/TableIndexPage/Table/Table';

const MyPage = () => {
  return (
    <TableIndexPage
      apiUrl="/api/v2/hosts"
      header={__('Hosts')}
      controller="hosts"
      replacementResponse={response}
      customToolbarItems={customToolbarItems}
      selectionToolbar={selectionToolbar}
    >
      <Table
        params={params}
        setParams={setParamsAndAPI}
        results={results}
        columns={columns}
        showCheckboxes={true}
        selectOne={selectOne}
        isSelected={isSelected}
      >
        {results?.map((result, rowIndex) => (
          <Tr key={rowIndex}>
            <RowSelectTd rowData={result} {...{ selectOne, isSelected }} />
            {/* Custom row rendering */}
          </Tr>
        ))}
      </Table>
    </TableIndexPage>
  );
};
```

**Key characteristics**:
- Pass custom `<Table>` component as children
- Full control over table rendering
- Can implement custom row logic
- More complex but more flexible

### Column Definition Object

```javascript
const columns = {
  column_key: {
    title: __('Column Title'),           // Required: Display title
    wrapper: (rowData) => <Component />, // Optional: Custom rendering function
    isSorted: true,                      // Optional: Enable sorting
  },
};
```

### Common Props

```javascript
<TableIndexPage
  // Required
  apiUrl="/api/v2/resource"
  header={__('Page Title')}

  // API Configuration
  apiOptions={{ key: 'UNIQUE_API_KEY' }}

  // Table Features
  searchable={true}
  creatable={true}
  isDeleteable={true}
  showCheckboxes={true}

  // Customization
  controller="resource_name"
  columns={columns}
  customActionButtons={actionButtons}
  customSearchProps={searchProps}

  // Data
  replacementResponse={response}  // Skip API call, use this data
/>
```

## useAPI Hook

Foreman's standardized hook for API requests with built-in state management.

### Basic Usage

```javascript
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';

const MyComponent = () => {
  const response = useAPI('get', '/api/v2/resources', {
    key: 'RESOURCES_KEY',
    params: { search: 'example' },
  });

  const { response: data, status, setAPIOptions } = response;

  // Update API parameters
  const handleSearch = (newSearch) => {
    setAPIOptions({
      params: { search: newSearch },
    });
  };

  return (
    <div>
      {status === 'PENDING' && <Spinner />}
      {data?.results?.map(item => <div key={item.id}>{item.name}</div>)}
    </div>
  );
};
```

### Advanced Patterns

#### Conditional API Calls

```javascript
// Only make API call when condition is met
const response = useAPI(
  shouldFetch ? 'get' : null,
  '/api/v2/resources',
  { key: 'CONDITIONAL_KEY' }
);
```

#### Dynamic URL Parameters

```javascript
const response = useAPI(
  'get',
  userId ? `/api/v2/users/${userId}/resources` : null,
  { key: 'USER_RESOURCES' }
);
```

#### Polling Pattern

```javascript
const [pollingIds, setPollingIds] = useState(new Set());

const statusResponse = useAPI(
  pollingIds.size > 0 ? 'get' : null,
  '/api/v2/status',
  {
    key: 'STATUS_POLLING',
    params: { ids: Array.from(pollingIds) },
  }
);

useEffect(() => {
  let intervalId;
  if (pollingIds.size > 0) {
    intervalId = setInterval(() => {
      statusResponse.setAPIOptions({
        params: { ids: Array.from(pollingIds) },
      });
    }, 3000);
  }
  return () => {
    if (intervalId) clearInterval(intervalId);
  };
}, [pollingIds, statusResponse]);
```

### API Action Helpers

For actions that don't need state management (fire-and-forget):

```javascript
import { post, delete as del } from 'foremanReact/redux/API';

const handleSync = async (repositoryIds) => {
  try {
    await post({
      url: '/api/v2/sync',
      params: { repository_ids: repositoryIds },
      successToast: 'Sync started successfully',
    });
  } catch (error) {
    console.error('Sync failed:', error);
  }
};

const handleDelete = async (itemId) => {
  try {
    await del({
      url: `/api/v2/items/${itemId}`,
      successToast: 'Item deleted successfully',
    });
  } catch (error) {
    console.error('Delete failed:', error);
  }
};
```

## Table-Specific Hooks

### useTableIndexAPIResponse

Specialized hook for TableIndexPage data fetching:

```javascript
import { useTableIndexAPIResponse } from 'foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks';

const response = useTableIndexAPIResponse({
  apiUrl: '/api/v2/resources',
  apiOptions: { key: 'RESOURCES_KEY' },
  defaultParams: { search: '', page: 1 },
  replacementResponse: mockData, // Optional: skip API call
});
```

### useBulkSelect

Handles bulk selection state and operations:

```javascript
import { useBulkSelect } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';

const {
  selectAll,
  selectPage,
  selectNone,
  selectedCount,
  selectOne,
  isSelected,
  selectedResults,
  fetchBulkParams,
} = useBulkSelect({
  results: tableData,
  metadata: { total, page, selectable: subtotal },
  initialSearchQuery: '',
});
```

## Migration from Redux to useAPI

When migrating existing Redux-based table components:

### Before (Redux)
```javascript
// Actions
export const getResources = (params) => (dispatch) => {
  return dispatch(get({
    url: '/api/v2/resources',
    params,
    key: 'RESOURCES_KEY',
  }));
};

// Component
const MyComponent = () => {
  const dispatch = useDispatch();
  const response = useSelector(selectResourcesResponse);

  useEffect(() => {
    dispatch(getResources());
  }, [dispatch]);

  return <div>{/* component */}</div>;
};
```

### After (useAPI)
```javascript
const MyComponent = () => {
  const response = useAPI('get', '/api/v2/resources', {
    key: 'RESOURCES_KEY',
  });

  return <div>{/* component */}</div>;
};
```

## Best Practices

1. **Use Declarative TableIndexPage** for standard CRUD operations
2. **Use unique API keys** to avoid state conflicts
3. **Implement polling carefully** with proper cleanup
4. **Use action helpers** for fire-and-forget operations
5. **Define columns with proper types** and sorting configuration
6. **Follow naming conventions** for controllers and API endpoints

## Common Gotchas

1. **API Key Conflicts**: Always use unique keys for different API calls
2. **Conditional API Calls**: Pass `null` as method to prevent unwanted calls
3. **Memory Leaks**: Clean up intervals and timeouts in useEffect
4. **State Updates**: Use setAPIOptions to update API parameters, not direct state
5. **Column Wrappers**: Remember that wrapper functions receive the full row data object

## Example: Complete Table Page

```javascript
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { translate as __ } from 'foremanReact/common/I18n';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import LongDateTime from 'foremanReact/components/common/dates/LongDateTime';

const MyResourcePage = () => {
  const [processingIds, setProcessingIds] = useState(new Set());

  // Polling for processing status
  const statusResponse = useAPI(
    processingIds.size > 0 ? 'get' : null,
    '/api/v2/my_resources/status',
    {
      key: 'RESOURCE_STATUS',
      params: { ids: Array.from(processingIds) },
    }
  );

  // Handle action
  const handleProcess = async (selectedResources) => {
    const ids = selectedResources.map(r => r.id);

    try {
      const { post } = await import('foremanReact/redux/API');
      await post({
        url: '/api/v2/my_resources/process',
        params: { resource_ids: ids },
        successToast: 'Processing started',
      });

      setProcessingIds(new Set([...processingIds, ...ids]));
    } catch (error) {
      console.error('Processing failed:', error);
    }
  };

  const columns = {
    name: {
      title: __('Name'),
      wrapper: (resource) => (
        <Link to={`/my_resources/${resource.id}`}>
          {resource.name}
        </Link>
      ),
      isSorted: true,
    },
    status: {
      title: __('Status'),
      wrapper: (resource) => {
        const status = statusMap.get(resource.id) || resource.status;
        return <StatusBadge status={status} />;
      },
    },
    created_at: {
      title: __('Created'),
      wrapper: (resource) => (
        <LongDateTime date={resource.created_at} />
      ),
      isSorted: true,
    },
  };

  const customActionButtons = [
    {
      title: __('Process Selected'),
      action: { onClick: handleProcess },
    },
  ];

  return (
    <TableIndexPage
      apiUrl="/api/v2/my_resources"
      apiOptions={{ key: 'MY_RESOURCES' }}
      header={__('My Resources')}
      controller="my_resources"
      columns={columns}
      customActionButtons={customActionButtons}
      searchable={true}
      creatable={true}
      showCheckboxes={true}
    />
  );
};

export default MyResourcePage;
```

## Reference Examples
- Simple [ModelsPage] (https://github.com/theforeman/foreman/blob/develop/webpack/assets/javascripts/react_app/routes/Models/ModelsPage/index.js)
- Complex: [HostsIndex](https://github.com/theforeman/foreman/blob/develop/webpack/assets/javascripts/react_app/components/HostsIndex/index.js)
- Katello: `./webpack/scenes/ContentViews/Table/ContentViewsTable.js`

This guide provides the foundation for building consistent, maintainable table-based interfaces in Katello following Foreman patterns.
