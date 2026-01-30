import { useEffect, useState } from 'react';

const modalState = {};
const listeners = {};

export const setBulkModalOpen = (id, isOpen) => {
  modalState[id] = isOpen;
  (listeners[id] || []).forEach(listener => listener(isOpen));
};

export const useBulkModalOpen = (id) => {
  const [isOpen, setIsOpen] = useState(Boolean(modalState[id]));

  useEffect(() => {
    if (!listeners[id]) listeners[id] = [];
    listeners[id].push(setIsOpen);
    return () => {
      listeners[id] = listeners[id].filter(listener => listener !== setIsOpen);
    };
  }, [id]);

  return [isOpen, open => setBulkModalOpen(id, open)];
};
