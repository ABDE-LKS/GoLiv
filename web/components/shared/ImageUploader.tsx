'use client';

import { useState, useRef } from 'react';
import Image from 'next/image';
import { Upload, X } from 'lucide-react';

interface ImageUploaderProps {
  onImagesSelected: (files: File[]) => void;
  maxImages?: number;
  maxFileSize?: number; // in bytes
  acceptedFormats?: string[];
}

export function ImageUploader({
  onImagesSelected,
  maxImages = 5,
  maxFileSize = 5 * 1024 * 1024, // 5MB default
  acceptedFormats = ['image/jpeg', 'image/png', 'image/webp'],
}: ImageUploaderProps) {
  const [selectedImages, setSelectedImages] = useState<Array<{ file: File; preview: string }>>([]);
  const [error, setError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileSelect = (files: FileList | null) => {
    if (!files) return;

    setError(null);
    const newImages: Array<{ file: File; preview: string }> = [];

    Array.from(files).forEach((file) => {
      // Check file size
      if (file.size > maxFileSize) {
        setError(`File "${file.name}" is too large. Maximum size is ${maxFileSize / 1024 / 1024}MB`);
        return;
      }

      // Check file type
      if (!acceptedFormats.includes(file.type)) {
        setError(`File type "${file.type}" is not supported`);
        return;
      }

      // Check if already selected
      if (selectedImages.some((img) => img.file.name === file.name)) {
        return;
      }

      // Create preview
      const reader = new FileReader();
      reader.onload = (e) => {
        newImages.push({
          file,
          preview: e.target?.result as string,
        });
        
        if (selectedImages.length + newImages.length <= maxImages) {
          setSelectedImages((prev) => [...prev, ...newImages]);
          onImagesSelected([...selectedImages, ...newImages].map((img) => img.file));
        } else {
          setError(`Maximum ${maxImages} images allowed`);
        }
      };
      reader.readAsDataURL(file);
    });
  };

  const removeImage = (index: number) => {
    const newImages = selectedImages.filter((_, i) => i !== index);
    setSelectedImages(newImages);
    onImagesSelected(newImages.map((img) => img.file));
    setError(null);
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    handleFileSelect(e.dataTransfer.files);
  };

  return (
    <div className="w-full">
      <div
        onDragOver={handleDragOver}
        onDrop={handleDrop}
        onClick={() => fileInputRef.current?.click()}
        className="relative border-2 border-dashed border-orange-200 rounded-lg p-8 text-center cursor-pointer hover:border-orange-400 transition-colors"
      >
        <input
          ref={fileInputRef}
          type="file"
          multiple
          accept={acceptedFormats.join(',')}
          onChange={(e) => handleFileSelect(e.target.files)}
          className="hidden"
        />
        <Upload className="mx-auto h-12 w-12 text-orange-400 mb-2" />
        <p className="text-sm font-medium text-foreground">Drag and drop images here</p>
        <p className="text-xs text-muted-foreground">or click to select files</p>
        <p className="text-xs text-muted-foreground mt-2">
          Max {maxImages} images, {maxFileSize / 1024 / 1024}MB each
        </p>
      </div>

      {error && (
        <div className="mt-2 text-sm text-red-500">
          {error}
        </div>
      )}

      {selectedImages.length > 0 && (
        <div className="mt-4">
          <p className="text-sm font-medium text-foreground mb-2">
            Selected images ({selectedImages.length}/{maxImages})
          </p>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-4">
            {selectedImages.map((image, index) => (
              <div key={index} className="relative group">
                <div className="relative w-full aspect-square rounded-lg overflow-hidden bg-muted">
                  <Image
                    src={image.preview}
                    alt={`Preview ${index}`}
                    fill
                    className="object-cover"
                  />
                </div>
                <button
                  onClick={() => removeImage(index)}
                  className="absolute top-1 right-1 bg-red-500 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
                >
                  <X size={16} />
                </button>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
