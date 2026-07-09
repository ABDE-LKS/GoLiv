'use client';

import { useState, useEffect } from 'react';
import { useParams } from 'next/navigation';
import { useInfiniteQuery } from '@tanstack/react-query';
import { useInView } from 'react-intersection-observer';
import { jobsService, JobFilters } from '@/lib/services/jobsService';
import Link from 'next/link';
import { Search, Filter, Briefcase, MapPin, DollarSign } from 'lucide-react';
import { formatPrice, getRelativeTime } from '@/lib/utils/helpers';
import { t, Locale } from '@/lib/i18n';

const jobTypes = [
  { value: 'FULL_TIME', label: 'Full Time' },
  { value: 'PART_TIME', label: 'Part Time' },
  { value: 'CONTRACT', label: 'Contract' },
  { value: 'TEMPORARY', label: 'Temporary' },
];

export default function JobsPage() {
  const [selectedJobType, setSelectedJobType] = useState<string>('');
  const [searchQuery, setSearchQuery] = useState('');
  const { ref, inView } = useInView();

  const {
    data,
    isLoading,
    hasNextPage,
    fetchNextPage,
    isFetchingNextPage,
  } = useInfiniteQuery({
    queryKey: ['jobs', selectedJobType, searchQuery],
    queryFn: async ({ pageParam = 1 }) => {
      const response = await jobsService.getJobs({
        jobType: selectedJobType || undefined,
        page: pageParam,
        limit: 20,
      });
      return response;
    },
    getNextPageParam: (lastPage) => {
      if (lastPage.hasMore) {
        return lastPage.page + 1;
      }
      return undefined;
    },
    initialPageParam: 1,
  });

  useEffect(() => {
    if (inView && hasNextPage && !isFetchingNextPage) {
      fetchNextPage();
    }
  }, [inView, hasNextPage, isFetchingNextPage, fetchNextPage]);

  const allJobs = data?.pages.flatMap((page) => page.data) || [];

  return (
    <div className="p-6 lg:p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-foreground mb-6">Job Opportunities</h1>

        <div className="grid md:grid-cols-2 gap-4 mb-6">
          <div className="relative">
            <Search className="absolute left-3 top-3 text-muted-foreground" size={20} />
            <input
              type="text"
              placeholder="Search jobs..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-border rounded-lg bg-background text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>

          <div className="flex gap-2">
            <Filter className="w-10 h-10 p-2 border border-border rounded-lg bg-background text-foreground" />
            <select
              value={selectedJobType}
              onChange={(e) => setSelectedJobType(e.target.value)}
              className="flex-1 px-4 py-2 border border-border rounded-lg bg-background text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="">All Job Types</option>
              {jobTypes.map((type) => (
                <option key={type.value} value={type.value}>
                  {type.label}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {isLoading ? (
        <div className="flex items-center justify-center py-12">
          <div className="animate-spin">
            <div className="w-12 h-12 border-4 border-primary/20 border-t-primary rounded-full"></div>
          </div>
        </div>
      ) : allJobs.length === 0 ? (
        <div className="text-center py-12">
          <p className="text-muted-foreground">No jobs found</p>
        </div>
      ) : (
        <>
          <div className="space-y-4">
            {allJobs.map((job) => (
              <Link
                key={job.id}
                href={`/jobs/${job.id}`}
                className="block bg-white dark:bg-card rounded-lg border border-border p-6 hover:shadow-lg transition-shadow"
              >
                <div className="flex items-start justify-between mb-3">
                  <div>
                    <h3 className="text-xl font-semibold text-foreground hover:text-primary transition-colors">
                      {job.title}
                    </h3>
                    <p className="text-muted-foreground">{job.company}</p>
                  </div>
                  <span className="px-3 py-1 bg-blue-100 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400 rounded-full text-sm font-medium">
                    {job.jobType}
                  </span>
                </div>

                <p className="text-foreground mb-4 line-clamp-2">{job.description}</p>

                <div className="flex flex-wrap gap-4 text-sm">
                  <div className="flex items-center gap-2 text-muted-foreground">
                    <MapPin size={16} />
                    <span>{job.location}</span>
                  </div>
                  {job.salary && (
                    <div className="flex items-center gap-2 text-primary font-medium">
                      <DollarSign size={16} />
                      <span>{formatPrice(job.salary)}</span>
                    </div>
                  )}
                  <div className="flex items-center gap-2 text-muted-foreground">
                    <Briefcase size={16} />
                    <span>{getRelativeTime(job.createdAt)}</span>
                  </div>
                </div>
              </Link>
            ))}
          </div>

          {hasNextPage && (
            <div ref={ref} className="flex justify-center mt-8">
              {isFetchingNextPage && (
                <div className="animate-spin">
                  <div className="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full"></div>
                </div>
              )}
            </div>
          )}
        </>
      )}
    </div>
  );
}
