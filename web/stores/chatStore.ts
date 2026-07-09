import { create } from 'zustand';
import { Conversation, Message } from '@/types';

interface ChatStore {
  conversations: Conversation[];
  selectedConversation: Conversation | null;
  messages: Map<string, Message[]>;
  isLoading: boolean;
  error: string | null;
  unreadCount: number;

  // Actions
  setConversations: (conversations: Conversation[]) => void;
  addConversation: (conversation: Conversation) => void;
  selectConversation: (conversation: Conversation) => void;
  setMessages: (conversationId: string, messages: Message[]) => void;
  addMessage: (conversationId: string, message: Message) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
  setUnreadCount: (count: number) => void;
  clearChat: () => void;
}

export const useChatStore = create<ChatStore>((set, get) => ({
  conversations: [],
  selectedConversation: null,
  messages: new Map(),
  isLoading: false,
  error: null,
  unreadCount: 0,

  setConversations: (conversations: Conversation[]) => {
    set({ conversations });
  },

  addConversation: (conversation: Conversation) => {
    set((state) => ({
      conversations: [conversation, ...state.conversations],
    }));
  },

  selectConversation: (conversation: Conversation) => {
    set({ selectedConversation: conversation });
  },

  setMessages: (conversationId: string, messages: Message[]) => {
    set((state) => {
      const newMessages = new Map(state.messages);
      newMessages.set(conversationId, messages);
      return { messages: newMessages };
    });
  },

  addMessage: (conversationId: string, message: Message) => {
    set((state) => {
      const newMessages = new Map(state.messages);
      const existing = newMessages.get(conversationId) || [];
      newMessages.set(conversationId, [...existing, message]);
      return { messages: newMessages };
    });
  },

  setLoading: (loading: boolean) => {
    set({ isLoading: loading });
  },

  setError: (error: string | null) => {
    set({ error });
  },

  setUnreadCount: (count: number) => {
    set({ unreadCount: count });
  },

  clearChat: () => {
    set({
      conversations: [],
      selectedConversation: null,
      messages: new Map(),
      unreadCount: 0,
    });
  },
}));
