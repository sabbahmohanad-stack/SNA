using System;

namespace SNA.Domain.Entities.Core
{
    /// <summary>
    /// Base entity class for all domain entities
    /// Includes common audit and tracking properties
    /// </summary>
    public abstract class BaseEntity
    {
        /// <summary>Primary key</summary>
        public Guid Id { get; set; } = Guid.NewGuid();

        /// <summary>When the record was created</summary>
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;

        /// <summary>User ID who created the record</summary>
        public Guid CreatedByUserId { get; set; }

        /// <summary>When the record was last modified</summary>
        public DateTime ModifiedDate { get; set; } = DateTime.UtcNow;

        /// <summary>User ID who last modified the record</summary>
        public Guid? ModifiedByUserId { get; set; }

        /// <summary>Is this record deleted (soft delete)</summary>
        public bool IsDeleted { get; set; } = false;

        /// <summary>Optimistic concurrency version</summary>
        public int Version { get; set; } = 1;
    }
}
