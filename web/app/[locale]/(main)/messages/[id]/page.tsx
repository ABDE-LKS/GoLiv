'use client';

import { useEffect, useRef, useState } from 'react';
import { useQuery, useMutation } from '@tanstack/react-query';
import { useParams, useRouter } from 'next/navigation';
import { chatService } from '@/lib/services/chatService';
import { initializeSocket, onNewMessage, emitTyping } from '@/lib/socket';
import { useAuthStore } from '@/stores/authStore';
import { useInView } from 'react-intersection-observer';
import Link from 'next/link';
import { Send, Phone, Video, MoreVertical, User } from 'lucide-react';
import { formatDate, getRelativeTime } from '@/lib/utils/helpers';

export default function ChatDetailPage() {
  const params = useParams();
  const router = useRouter();
  const conversationId = params.id as string;
  const { user } = useAuthStore();

  const [messages, setMessages] = useState<any[]>([]);
  const [messageInput, setMessageInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const [isLoadingMore, setIsLoadingMore] = useState(false);

  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const { ref: loadMoreRef, inView: shouldLoadMore } = useInView();

  // Fetch conversation
  const { data: conversation, isLoading } = useQuery({
    queryKey: ['conversation', conversationId],
    queryFn: () => chatService.getConversationById(conversationId),
  });

  // Fetch messages
  const { data: messagesData } = useQuery({
    queryKey: ['messages', conversationId],
    queryFn: () => chatService.getMessages(conversationId, 50, 0),
  });

  // Send message mutation
  const { mutate: sendMessage, isPending: isSending } = useMutation({
    mutationFn: (content: string) =>
      chatService.sendMessage(conversationId, {
        content,
        images: [],
      }),
    onSuccess: (newMessage) => {
      setMessages((prev) => [...prev, newMessage]);
      setMessageInput('');
      scrollToBottom();
    },
  });

  // Initialize messages
  useEffect(() => {
    if (messagesData?.data) {
      setMessages(messagesData.data);
      scrollToBottom();
    }
  }, [messagesData]);

  // Initialize Socket.io
  useEffect(() => {
    const socket = initializeSocket(user?.id || '');
    
    onNewMessage((message: any) => {
      if (message.conversationId === conversationId) {
        setMessages((prev) => [...prev, message]);
        scrollToBottom();
      }
    });

    return () => {
      // Cleanup socket on unmount
    };
  }, [conversationId, user?.id]);

  // Auto-scroll to bottom on new messages
  const scrollToBottom = () => {
    setTimeout(() => {
      messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    }, 0);
  };

  // Handle typing indicator
  const handleTyping = () => {
    emitTyping(conversationId);
  };

  // Handle sending message
  const handleSendMessage = (e: React.FormEvent) => {
    e.preventDefault();
    if (!messageInput.trim() || isSending) return;
    sendMessage(messageInput);
  };

  // Load more messages
  useEffect(() => {
    if (shouldLoadMore && !isLoadingMore) {
      setIsLoadingMore(true);
      // TODO: Load more messages
      setIsLoadingMore(false);
    }
  }, [shouldLoadMore, isLoadingMore]);

  if (isLoading) {
    return (
      <div className="p-6 lg:p-8 flex items-center justify-center min-h-screen">
        <div className="animate-spin">
          <div className="w-12 h-12 border-4 border-primary/20 border-t-primary rounded-full"></div>
        </div>
      </div>
    );
  }

  if (!conversation) {
    return (
      <div className="p-6 lg:p-8">
        <p className="text-muted-foreground">Conversation not found</p>
      </div>
    );
  }

  const otherParticipant = conversation.participants.find((p: any) => p.id !== user?.id);

  return (
    <div className="h-screen flex flex-col p-6 lg:p-8">
      {/* Header */}
      <div className="bg-white dark:bg-card border border-border rounded-lg p-4 mb-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-primary text-primary-foreground rounded-full flex items-center justify-center font-semibold">
            {otherParticipant?.firstName?.[0]}{otherParticipant?.lastName?.[0]}
          </div>
          <div>
            <h2 className="font-semibold text-foreground">
              {otherParticipant?.firstName} {otherParticipant?.lastName}
            </h2>
            <p className="text-xs text-muted-foreground">Active 2 minutes ago</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button className="p-2 hover:bg-muted rounded-lg transition-colors">
            <Phone size={20} className="text-muted-foreground" />
          </button>
          <button className="p-2 hover:bg-muted rounded-lg transition-colors">
            <Video size={20} className="text-muted-foreground" />
          </button>
          <button className="p-2 hover:bg-muted rounded-lg transition-colors">
            <MoreVertical size={20} className="text-muted-foreground" />
          </button>
        </div>
      </div>

      {/* Messages Container */}
      <div
        ref={scrollContainerRef}
        className="flex-1 overflow-y-auto bg-white dark:bg-card border border-border rounded-lg p-4 mb-4 space-y-4"
      >
        {messages.length === 0 ? (
          <div className="flex items-center justify-center h-full">
            <p className="text-muted-foreground">No messages yet. Start the conversation!</p>
          </div>
        ) : (
          <>
            <div ref={loadMoreRef} className="flex justify-center py-2">
              {isLoadingMore && (
                <div className="text-sm text-muted-foreground">Loading older messages...</div>
              )}
            </div>

            {messages.map((message, index) => (
              <div
                key={message.id}
                className={`flex ${
                  message.senderId === user?.id ? 'justify-end' : 'justify-start'
                }`}
              >
                <div
                  className={`max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${
                    message.senderId === user?.id
                      ? 'bg-primary text-primary-foreground'
                      : 'bg-muted text-foreground'
                  }`}
                >
                  <p className="break-words">{message.content}</p>
                  <p
                    className={`text-xs mt-1 ${
                      message.senderId === user?.id
                        ? 'text-primary-foreground/70'
                        : 'text-muted-foreground'
                    }`}
                  >
                    {formatDate(message.createdAt)}
                  </p>
                </div>
              </div>
            ))}

            {isTyping && (
              <div className="flex justify-start">
                <div className="bg-muted text-foreground px-4 py-2 rounded-lg">
                  <div className="flex gap-1">
                    <div className="w-2 h-2 bg-foreground/50 rounded-full animate-bounce"></div>
                    <div className="w-2 h-2 bg-foreground/50 rounded-full animate-bounce delay-100"></div>
                    <div className="w-2 h-2 bg-foreground/50 rounded-full animate-bounce delay-200"></div>
                  </div>
                </div>
              </div>
            )}

            <div ref={messagesEndRef} />
          </>
        )}
      </div>

      {/* Message Input */}
      <form onSubmit={handleSendMessage} className="flex gap-2">
        <input
          type="text"
          placeholder="Type a message..."
          value={messageInput}
          onChange={(e) => {
            setMessageInput(e.target.value);
            handleTyping();
          }}
          onKeyDown={(e) => {
            if (e.key === 'Enter' && !e.nativeEvent.isComposing) {
              handleSendMessage(e);
            }
          }}
          disabled={isSending}
          className="flex-1 px-4 py-3 border border-border rounded-lg bg-background text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary disabled:opacity-50"
        />
        <button
          type="submit"
          disabled={!messageInput.trim() || isSending}
          className="px-4 py-3 bg-primary text-primary-foreground rounded-lg hover:bg-orange-600 transition-colors disabled:opacity-50 flex items-center gap-2"
        >
          <Send size={20} />
        </button>
      </form>
    </div>
  );
}
