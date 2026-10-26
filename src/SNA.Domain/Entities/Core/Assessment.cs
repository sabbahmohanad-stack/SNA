using System;

namespace SNA.Domain.Entities.Core
{
    /// <summary>Assessment results associated with a case.</summary>
    public class Assessment : BaseEntity
    {
        public Guid CaseId { get; set; }
        public string AssessmentType { get; set; }
        public string AssessmentName { get; set; }
        public DateTime DateAdministered { get; set; }
        public DateTime? DateCompleted { get; set; }
        public Guid AssessorId { get; set; }
        public decimal? TotalScore { get; set; }
        public decimal? PercentileRank { get; set; }
        public decimal? StandardScore { get; set; }
        public string AgeEquivalent { get; set; }
        public string KeyFindings { get; set; }
        public string Strengths { get; set; }
        public string Weaknesses { get; set; }
        public string Recommendations { get; set; }
        public string AssessmentDocument { get; set; }
        public AssessmentStatus Status { get; set; } = AssessmentStatus.Pending;

        public virtual Case Case { get; set; }
    }

    public enum AssessmentStatus
    {
        Pending,
        Completed,
        Archived
    }
}
