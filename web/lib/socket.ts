import io, { Socket } from 'socket.io-client';

let socket: Socket | null = null;

export function initializeSocket(token: string) {
  if (socket) {
    return socket;
  }

  socket = io(process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001', {
    auth: {
      token,
    },
    reconnection: true,
    reconnectionDelay: 1000,
    reconnectionDelayMax: 5000,
    reconnectionAttempts: 5,
  });

  socket.on('connect', () => {
    console.log('[Socket] Connected');
  });

  socket.on('disconnect', () => {
    console.log('[Socket] Disconnected');
  });

  socket.on('error', (error) => {
    console.error('[Socket] Error:', error);
  });

  return socket;
}

export function getSocket(): Socket | null {
  return socket;
}

export function disconnectSocket() {
  if (socket) {
    socket.disconnect();
    socket = null;
  }
}

// Event listeners
export function onNewMessage(callback: (data: any) => void) {
  if (socket) {
    socket.on('message:new', callback);
  }
}

export function onMessageRead(callback: (data: any) => void) {
  if (socket) {
    socket.on('message:read', callback);
  }
}

export function onUserTyping(callback: (data: any) => void) {
  if (socket) {
    socket.on('user:typing', callback);
  }
}

export function onNotification(callback: (data: any) => void) {
  if (socket) {
    socket.on('notification:new', callback);
  }
}

// Emit functions
export function emitTyping(conversationId: string) {
  if (socket) {
    socket.emit('user:typing', { conversationId });
  }
}

export function emitMessageRead(messageId: string) {
  if (socket) {
    socket.emit('message:read', { messageId });
  }
}

export function emitConversationRead(conversationId: string) {
  if (socket) {
    socket.emit('conversation:read', { conversationId });
  }
}
