'use client';

import { useEffect, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useChatStore } from '@/stores/chatStore';
import { chatService } from '@/lib/services/chatService';
import Link from 'next/link';
import { MessageCircle, Search } from 'lucide-react';
import { formatDate, getRelativeTime } from '@/lib/utils/helpers';
import { EmptyState } from '@/components/shared/EmptyState';

export default function MessagesPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const { conversations, setConversations } = useChatStore();

  const { isLoading } = useQuery({
    queryKey: ['conversations'],
    queryFn: async () => {
      const response = await chatService.getConversations(50, 0);
      setConversations(response.data);
      return response;
    },
  });

  const filteredConversations = conversations.filter((conv) => {
    const participantName = conv.participants
      .map((p) => `${p.firstName} ${p.lastName}`)
      .join(' ')
      .toLowerCase();
    return participantName.includes(searchQuery.toLowerCase());
  });

  return (
    <div className="p-6 lg:p-8">
      <h1 className="text-3xl font-bold text-foreground mb-6">Messages</h1>

      {/* Search */}
      <div className="mb-6">
        <div className="relative">
          <Search className="absolute left-3 top-3 text-muted-foreground" size={20} />
          <input
            type="text"
            placeholder="Search conversations..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-border rounded-lg bg-background text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary"
          />
        </div>
      </div>

      {isLoading ? (
        <div className="flex items-center justify-center py-12">
          <div className="animate-spin">
            <div className="w-12 h-12 border-4 border-primary/20 border-t-primary rounded-full"></div>
          </div>
        </div>
      ) : filteredConversations.length === 0 ? (
        <EmptyState
          icon={MessageCircle}
          title="No Conversations"
          description="You haven't started any conversations yet. Browse listings and contact sellers to start messaging."
          action={{
            label: 'Browse Marketplace',
            onClick: () => window.location.href = '/marketplace',
          }}
        />
      ) : (
        <div className="grid gap-4">
          {filteredConversations.map((conversation) => {
            const otherParticipant = conversation.participants[0];

            return (
              <Link
                key={conversation.id}
                href={`/messages/${conversation.id}`}
                className="bg-white dark:bg-card rounded-lg border border-border p-4 hover:shadow-lg transition-shadow"
              >
                <div className="flex items-start justify-between">
                  <div className="flex gap-4 flex-1">
                    <div className="w-12 h-12 bg-primary text-primary-foreground rounded-full flex items-center justify-center flex-shrink-0 font-semibold">
                      {otherParticipant.firstName[0]}{otherParticipant.lastName[0]}
                    </div>
                    <div className="flex-1">
                      <h3 className="font-semibold text-foreground">
                        {otherParticipant.firstName} {otherParticipant.lastName}
                      </h3>
                      <p className="text-sm text-muted-foreground line-clamp-1">
                        {conversation.lastMessage?.content || 'No messages yet'}
                      </p>
                    </div>
                  </div>
                  <div className="text-right flex-shrink-0">
                    <p className="text-xs text-muted-foreground">
                      {getRelativeTime(conversation.lastMessageAt)}
                    </p>
                    {conversation.unreadCount > 0 && (
                      <div className="mt-1 inline-block px-2 py-1 bg-primary text-primary-foreground text-xs rounded-full font-semibold">
                        {conversation.unreadCount}
                      </div>
                    )}
                  </div>
                </div>
              </Link>
            );
          })}
        </div>
      )}
    </div>
  );
}
