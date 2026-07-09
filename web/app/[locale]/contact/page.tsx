'use client';

import { useState } from 'react';
import { useParams } from 'next/navigation';
import { t, Locale } from '@/lib/i18n';
import { Mail, Phone, MapPin, Send } from 'lucide-react';

export default function ContactPage() {
  const params = useParams();
  const locale = (params.locale as Locale) || 'ar';
  const translate = (key: string) => t(locale, key);

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    subject: '',
    message: '',
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    // Simulate form submission
    await new Promise(r => setTimeout(r, 1000));
    setSubmitted(true);
    setIsSubmitting(false);
    setFormData({ name: '', email: '', subject: '', message: '' });
  };

  return (
    <div style={{ backgroundColor: 'var(--background)', color: 'var(--foreground)' }} className="min-h-screen">
      {/* Navigation */}
      <nav className="sticky top-0 z-40 border-b backdrop-blur-sm" style={{ borderColor: 'var(--border)', backgroundColor: 'color-mix(in srgb, var(--card) 80%, transparent)' }}>
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <a href={`/${locale}`} className="text-2xl font-bold text-primary">GoLiv</a>
          <div className="flex gap-3 items-center">
            <a href={`/${locale}/auth/login`} className="text-sm hover:text-primary transition-colors">
              {translate('nav.signIn')}
            </a>
            <a
              href={`/${locale}/auth/register`}
              style={{ backgroundColor: 'var(--primary)', color: 'var(--primary-foreground)' }}
              className="px-4 py-2 rounded-lg hover:opacity-90 transition-opacity text-sm"
            >
              {translate('nav.getStarted')}
            </a>
          </div>
        </div>
      </nav>

      {/* Content */}
      <main className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="text-center mb-16">
          <h1 className="text-4xl font-bold mb-4">Get in Touch</h1>
          <p style={{ color: 'var(--muted-foreground)' }} className="text-lg">
            Have a question? We&apos;d love to hear from you. Send us a message and we&apos;ll respond as soon as possible.
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-12">
          {/* Contact Information */}
          <div className="space-y-8">
            <div className="flex gap-4">
              <div className="w-12 h-12 rounded-lg flex items-center justify-center flex-shrink-0" style={{ backgroundColor: 'color-mix(in srgb, var(--primary) 20%, transparent)' }}>
                <Mail className="text-primary" size={24} />
              </div>
              <div>
                <h3 className="font-semibold mb-1">Email</h3>
                <p style={{ color: 'var(--muted-foreground)' }}>support@goliv.dz</p>
              </div>
            </div>

            <div className="flex gap-4">
              <div className="w-12 h-12 rounded-lg flex items-center justify-center flex-shrink-0" style={{ backgroundColor: 'color-mix(in srgb, var(--primary) 20%, transparent)' }}>
                <Phone className="text-primary" size={24} />
              </div>
              <div>
                <h3 className="font-semibold mb-1">Phone</h3>
                <p style={{ color: 'var(--muted-foreground)' }}>+213 (0) 123 456 789</p>
              </div>
            </div>

            <div className="flex gap-4">
              <div className="w-12 h-12 rounded-lg flex items-center justify-center flex-shrink-0" style={{ backgroundColor: 'color-mix(in srgb, var(--primary) 20%, transparent)' }}>
                <MapPin className="text-primary" size={24} />
              </div>
              <div>
                <h3 className="font-semibold mb-1">Address</h3>
                <p style={{ color: 'var(--muted-foreground)' }}>Algiers, Algeria</p>
              </div>
            </div>
          </div>

          {/* Contact Form */}
          <div className="p-8 rounded-lg" style={{ backgroundColor: 'var(--card)', border: '1px solid var(--border)' }}>
            {submitted ? (
              <div className="text-center space-y-4 py-12">
                <div className="w-12 h-12 rounded-full mx-auto flex items-center justify-center" style={{ backgroundColor: 'color-mix(in srgb, var(--primary) 20%, transparent)' }}>
                  <Send className="text-primary" size={24} />
                </div>
                <h3 className="text-xl font-semibold">Thank you!</h3>
                <p style={{ color: 'var(--muted-foreground)' }}>Your message has been sent successfully. We'll get back to you soon.</p>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-2">Name</label>
                  <input
                    type="text"
                    value={formData.name}
                    onChange={(e) => setFormData({...formData, name: e.target.value})}
                    className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                    style={{ borderColor: 'var(--border)', backgroundColor: 'var(--background)', color: 'var(--foreground)' }}
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2">Email</label>
                  <input
                    type="email"
                    value={formData.email}
                    onChange={(e) => setFormData({...formData, email: e.target.value})}
                    className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                    style={{ borderColor: 'var(--border)', backgroundColor: 'var(--background)', color: 'var(--foreground)' }}
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2">Subject</label>
                  <input
                    type="text"
                    value={formData.subject}
                    onChange={(e) => setFormData({...formData, subject: e.target.value})}
                    className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                    style={{ borderColor: 'var(--border)', backgroundColor: 'var(--background)', color: 'var(--foreground)' }}
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2">Message</label>
                  <textarea
                    value={formData.message}
                    onChange={(e) => setFormData({...formData, message: e.target.value})}
                    rows={5}
                    className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                    style={{ borderColor: 'var(--border)', backgroundColor: 'var(--background)', color: 'var(--foreground)' }}
                    required
                  />
                </div>

                <button
                  type="submit"
                  disabled={isSubmitting}
                  style={{ backgroundColor: 'var(--primary)', color: 'var(--primary-foreground)' }}
                  className="w-full px-4 py-2 rounded-lg hover:opacity-90 transition-opacity disabled:opacity-50 flex items-center justify-center gap-2"
                >
                  {isSubmitting && <div className="w-4 h-4 border-2 border-current border-t-transparent rounded-full animate-spin"></div>}
                  {isSubmitting ? 'Sending...' : 'Send Message'}
                </button>
              </form>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}
