const mongoose = require('mongoose');

const faceEmbeddingSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  organizationId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Organization',
    required: false
  },
  embedding: {
    type: [Number], // Face embedding vector
    required: true
  },
  imageUrl: {
    type: String, // URL to stored image (GridFS or S3)
    required: true
  },
  imageMetadata: {
    width: Number,
    height: Number,
    format: String // 'jpg', 'png', etc.
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Indexes
faceEmbeddingSchema.index({ userId: 1 });
faceEmbeddingSchema.index({ organizationId: 1 });
faceEmbeddingSchema.index({ isActive: 1 });

module.exports = mongoose.model('FaceEmbedding', faceEmbeddingSchema);

