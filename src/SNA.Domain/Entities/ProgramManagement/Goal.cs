using System;
using System.Collections.Generic;
using SNA.Domain.Entities.Core;

namespace SNA.Domain.Entities.ProgramManagement
{
    /// <summary>
    /// Goal Entity - IEP/ISP Goals
    /// </summary>
    public class Goal : BaseEntity
    {
        /// <summary>The case this goal belongs to</summary>
        public Guid CaseId { get; set; }

        /// <summary>Goal number</summary>
        public int GoalNumber { get; set; }

        /// <summary>The goal statement</summary>
        public string GoalStatement { get; set; }

        /// <summary>Domain area</summary>
        public DomainArea DomainArea { get; set; }

        /// <summary>Specific objective statement</summary>
        public string ObjectiveStatement { get; set; }

        /// <summary>How progress will be measured</summary>
        public string MeasurementMethod { get; set; }

        /// <summary>Criteria for mastery</summary>
        public string CriteriaForMastery { get; set; }

        /// <summary>When data should be collected</summary>
        public string DataCollectionSchedule { get; set; }

        /// <summary>Timeline in weeks</summary>
        public int Timeline { get; set; }

        /// <summary>Target date for achievement</summary>
        public DateTime? TargetDate { get; set; }

        /// <summary>When goal started</summary>
        public DateTime StartDate { get; set; }

        /// <summary>When goal ended</summary>
        public DateTime? EndDate { get; set; }

        /// <summary>Current status</summary>
        public GoalStatus Status { get; set; } = GoalStatus.Active;

        /// <summary>Current progress percentage</summary>
        public decimal ProgressPercentage { get; set; } = 0;

        /// <summary>Related behaviors (JSON array of Behavior IDs)</summary>
        public string RelatedBehaviorIds { get; set; }

        /// <summary>IEP review date</summary>
        public DateTime? IEPReviewDate { get; set; }

        /// <summary>Notes about the goal</summary>
        public string Notes { get; set; }

        // Navigation properties
        public virtual Case Case { get; set; }
        public virtual List<Program> Programs { get; set; } = new();
    }

    /// <summary>Domain Area</summary>
    public enum DomainArea
    {
        Communication,   // Speech/Language
        Social,          // Social/Interaction
        Academic,        // Academic skills
        Motor,           // Motor skills
        Behavior,        // Behavior management
        SelfCare,        // Self-care/ADL
        Vocational,      // Vocational/Work
        Other            // Other areas
    }

    /// <summary>Goal Status</summary>
    public enum GoalStatus
    {
        Active,          // Currently active
        Achieved,        // Successfully achieved
        Modified,        // Modified
        Discontinued,    // Discontinued
        Archived         // Archived
    }
}
