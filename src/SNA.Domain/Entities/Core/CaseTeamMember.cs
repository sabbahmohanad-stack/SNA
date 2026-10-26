using System;

namespace SNA.Domain.Entities.Core
{
    /// <summary>Records a user's assignment to a case team.</summary>
    public class CaseTeamMember : BaseEntity
    {
        public Guid CaseId { get; set; }
        public Guid UserId { get; set; }
        public string Role { get; set; }
        public DateTime DateAssigned { get; set; } = DateTime.UtcNow;
        public DateTime? DateUnassigned { get; set; }
        public bool IsActive { get; set; } = true;

        public virtual Case Case { get; set; }
    }
}
