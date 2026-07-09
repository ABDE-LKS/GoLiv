'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  Home,
  ShoppingCart,
  Wrench,
  Briefcase,
  MessageSquare,
  Package,
  Heart,
  Settings,
  X,
} from 'lucide-react';

interface SidebarProps {
  isOpen: boolean;
  onClose: () => void;
}

const menuItems = [
  { label: 'Dashboard', href: '/dashboard', icon: Home },
  { label: 'Marketplace', href: '/marketplace', icon: ShoppingCart },
  { label: 'My Listings', href: '/my-listings', icon: Package },
  { label: 'Services', href: '/services', icon: Wrench },
  { label: 'Jobs', href: '/jobs', icon: Briefcase },
  { label: 'Favorites', href: '/favorites', icon: Heart },
  { label: 'Messages', href: '/messages', icon: MessageSquare },
  { label: 'Settings', href: '/settings', icon: Settings },
];

export default function Sidebar({ isOpen, onClose }: SidebarProps) {
  const pathname = usePathname();

  const isActive = (href: string) => {
    return pathname === href || pathname.startsWith(href + '/');
  };

  return (
    <>
      {/* Mobile Overlay */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-black/50 lg:hidden z-30"
          onClick={onClose}
        />
      )}

      {/* Sidebar */}
      <aside
        className={`fixed lg:static left-0 top-0 h-screen w-64 bg-white dark:bg-card border-r border-border transform transition-transform duration-300 lg:translate-x-0 z-40 overflow-y-auto ${
          isOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        {/* Close Button (Mobile) */}
        <div className="lg:hidden flex items-center justify-between p-4 border-b border-border">
          <span className="font-bold text-lg text-primary">GoLiv</span>
          <button
            onClick={onClose}
            className="p-2 hover:bg-muted rounded-lg transition-colors"
          >
            <X size={24} />
          </button>
        </div>

        {/* Menu Items */}
        <nav className="p-4 space-y-2">
          {menuItems.map((item) => {
            const Icon = item.icon;
            const active = isActive(item.href);

            return (
              <Link
                key={item.href}
                href={item.href}
                onClick={onClose}
                className={`flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${
                  active
                    ? 'bg-orange-100 dark:bg-orange-900/20 text-primary font-semibold'
                    : 'text-foreground hover:bg-muted'
                }`}
              >
                <Icon size={20} />
                <span>{item.label}</span>
              </Link>
            );
          })}
        </nav>

        {/* Create Ad Button */}
        <div className="p-4 border-t border-border">
          <Link
            href="/create-listing"
            className="w-full block px-4 py-3 bg-primary text-primary-foreground rounded-lg hover:bg-orange-600 transition-colors text-center font-semibold"
            onClick={onClose}
          >
            Create Listing
          </Link>
        </div>
      </aside>
    </>
  );
}
