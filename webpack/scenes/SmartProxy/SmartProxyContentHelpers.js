export const pendingCountTasksForProxy = (tasks, smartProxyId) => {
  const proxyId = String(smartProxyId);

  return (tasks || []).filter((task) => {
    const input = task.input || {};

    if (input.smart_proxy_id != null && String(input.smart_proxy_id) === proxyId) {
      return true;
    }

    if (input.smart_proxy?.id != null && String(input.smart_proxy.id) === proxyId) {
      return true;
    }

    return task.resource_id != null && String(task.resource_id) === proxyId;
  });
};

export default pendingCountTasksForProxy;
