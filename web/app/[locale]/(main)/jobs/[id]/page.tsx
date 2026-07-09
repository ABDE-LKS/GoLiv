'use client';

import { useEffect, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useParams, useRouter } from 'next/navigation';
import { jobsService } from '@/lib/services/jobsService';
import { chatService } from '@/lib/services/chatService';
import Link from 'next/link';
import { Heart, Share2, Flag, MessageCircle, MapPin, User, Calendar, Briefcase, DollarSign, Send } from 'lucide-react';
import { formatPrice, formatDate, getRelativeTime } from '@/lib/utils/helpers';

export default function JobDetailPage() {
  const params = useParams();
  const router = useRouter();
  const jobId = params.id as string;
  const [isApplying, setIsApplying] = useState(false);

  const { data: job, isLoading } = useQuery({
    queryKey: ['job', jobId],
    queryFn: () => jobsService.getJobById(jobId),
  });

  const handleContactPoster = async () => {
    try {
      const conversation = await chatService.createConversation(job!.postedById);
      router.push(`/messages/${conversation.id}`);
    } catch (error) {
      console.error('Error creating conversation:', error);
    }
  };

  const handleApplyJob = async () => {
    // TODO: Open application modal/form
    setIsApplying(true);
    console.log('Apply to job:', jobId);
  };

  if (isLoading) {
    return (
      <div className="p-6 lg:p-8 flex items-center justify-center min-h-screen">
        <div className="animate-spin">
          <div className="w-12 h-12 border-4 border-primary/20 border-t-primary rounded-full"></div>
        </div>
      </div>
    );
  }

  if (!job) {
    return (
      <div className="p-6 lg:p-8">
        <p className="text-muted-foreground">Job not found</p>
      </div>
    );
  }

  return (
    <div className="p-6 lg:p-8">
      <div className="grid lg:grid-cols-3 gap-8">
        {/* Main Content */}
        <div className="lg:col-span-2">
          <div className="bg-white dark:bg-card rounded-lg p-6 border border-border mb-4">
            <div className="mb-6">
              <div className="flex items-start justify-between mb-4">
                <div>
                  <h1 className="text-3xl font-bold text-foreground mb-2">{job.title}</h1>
                  <p className="text-lg text-primary font-semibold">{job.company}</p>
                </div>
                <span className="px-4 py-2 bg-blue-100 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400 rounded-full text-sm font-medium">
                  {job.jobType.replace(/_/g, ' ')}
                </span>
              </div>

              <div className="flex flex-wrap gap-4 mb-6">
                <div className="flex items-center gap-2 text-muted-foreground">
                  <MapPin size={18} />
                  <span>{job.location}</span>
                </div>
                <div className="flex items-center gap-2 text-muted-foreground">
                  <Calendar size={18} />
                  <span>{getRelativeTime(job.createdAt)}</span>
                </div>
                {job.salary && (
                  <div className="flex items-center gap-2 text-primary font-semibold">
                    <DollarSign size={18} />
                    <span>{formatPrice(job.salary)}</span>
                  </div>
                )}
                <div className="flex items-center gap-2 text-muted-foreground">
                  <Briefcase size={18} />
                  <span>{job.applications || 0} applied</span>
                </div>
              </div>
            </div>

            <div className="mb-6 pb-6 border-b border-border">
              <h3 className="font-semibold text-foreground mb-3">Job Description</h3>
              <p className="text-foreground leading-relaxed whitespace-pre-wrap">{job.description}</p>
            </div>

            <div className="bg-muted/50 rounded-lg p-4">
              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <p className="text-sm text-muted-foreground mb-1">Job Type</p>
                  <p className="font-medium text-foreground">{job.jobType.replace(/_/g, ' ')}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground mb-1">Status</p>
                  <p className="font-medium text-foreground capitalize">{job.status.toLowerCase()}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground mb-1">Location</p>
                  <p className="font-medium text-foreground">{job.location}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground mb-1">Posted</p>
                  <p className="font-medium text-foreground">{formatDate(job.createdAt)}</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Sidebar */}
        <div>
          {/* Action Card */}
          <div className="bg-white dark:bg-card rounded-lg p-6 border border-border mb-4 sticky top-24">
            {job.salary && (
              <div className="mb-6 pb-6 border-b border-border">
                <p className="text-sm text-muted-foreground mb-1">Salary</p>
                <p className="text-2xl font-bold text-primary">{formatPrice(job.salary)}</p>
              </div>
            )}

            <button
              onClick={handleApplyJob}
              disabled={isApplying}
              className="w-full px-4 py-3 bg-primary text-primary-foreground rounded-lg hover:bg-orange-600 transition-colors font-semibold mb-2 flex items-center justify-center gap-2 disabled:opacity-50"
            >
              <Send size={20} />
              {isApplying ? 'Applying...' : 'Apply Now'}
            </button>

            <button
              onClick={handleContactPoster}
              className="w-full px-4 py-3 border border-primary text-primary rounded-lg hover:bg-orange-50 dark:hover:bg-orange-900/20 transition-colors font-semibold mb-4 flex items-center justify-center gap-2"
            >
              <MessageCircle size={20} />
              Contact Employer
            </button>

            <div className="flex gap-2 mb-6">
              <button className="flex-1 px-3 py-2 border border-border text-foreground rounded-lg hover:bg-muted transition-colors flex items-center justify-center gap-2">
                <Heart size={20} />
                <span>Save</span>
              </button>
              <button className="flex-1 px-3 py-2 border border-border text-foreground rounded-lg hover:bg-muted transition-colors flex items-center justify-center gap-2">
                <Share2 size={20} />
                <span>Share</span>
              </button>
            </div>

            <button className="w-full px-4 py-2 border border-red-200 text-red-600 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors flex items-center justify-center gap-2 text-sm">
              <Flag size={18} />
              Report
            </button>
          </div>

          {/* Employer Info */}
          <div className="bg-white dark:bg-card rounded-lg p-6 border border-border">
            <h3 className="font-semibold text-foreground mb-4">Employer Information</h3>

            <div className="flex items-center gap-4 pb-4 border-b border-border mb-4">
              <div className="w-12 h-12 bg-primary text-primary-foreground rounded-full flex items-center justify-center font-semibold text-lg">
                {job.postedBy.firstName[0]}{job.postedBy.lastName[0]}
              </div>
              <div>
                <p className="font-semibold text-foreground">
                  {job.postedBy.firstName} {job.postedBy.lastName}
                </p>
                <p className="text-sm text-muted-foreground">Employer</p>
              </div>
            </div>

            <Link
              href={`/profile/${job.postedBy.id}`}
              className="w-full px-4 py-2 border border-primary text-primary rounded-lg hover:bg-orange-50 dark:hover:bg-orange-900/20 transition-colors text-center font-medium"
            >
              View Profile
            </Link>
          </div>

          {/* Quick Stats */}
          <div className="bg-white dark:bg-card rounded-lg p-6 border border-border mt-4">
            <h3 className="font-semibold text-foreground mb-4">Job Stats</h3>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-muted-foreground">Applications</span>
                <span className="font-medium text-foreground">{job.applications || 0}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">Posted</span>
                <span className="font-medium text-foreground">{getRelativeTime(job.createdAt)}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
