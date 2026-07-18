using System;
using System.Collections.Generic;
using SNA.Domain.Entities.BehaviorAnalysis;
using SNA.Domain.Entities.Core;
using SNA.Domain.Entities.SessionManagement;

namespace SNA.Domain.Entities.ProgramManagement
{
    /// <summary>
    /// Program Entity - Treatment/Intervention Program
    /// Combines behavior, replacement skill, and intervention plan
    /// </summary>
    public class Program : BaseEntity
    {
        /// <summary>The case this program belongs to</summary>
        public Guid CaseId { get; set; }

        /// <summary>Name of the program</summary>
        public string ProgramName { get; set; }

        /// <summary>The behavior being addressed</summary>
        public Guid BehaviorId { get; set; }

        /// <summary>Related goal (optional)</summary>
        public Guid? RelatedGoalId { get; set; }

        /// <summary>Replacement skill being taught</summary>
        public Guid? ReplacementSkillId { get; set; }

        /// <summary>Description of the program</summary>
        public string ProgramDescription { get; set; }

        /// <summary>When the program started</summary>
        public DateTime StartDate { get; set; }

        /// <summary>Target end date</summary>
        public DateTime? TargetEndDate { get; set; }

        /// <summary>Actual end date</summary>
        public DateTime? ActualEndDate { get; set; }

        /// <summary>Current status</summary>
        public ProgramStatus Status { get; set; } = ProgramStatus.Active;

        /// <summary>Target mastery percentage</summary>
        public decimal MasteryTarget { get; set; } = 80;

        /// <summary>How data will be collected</summary>
        public string DataCollectionMethod { get; set; }

        /// <summary>Number of trials per session</summary>
        public int? TrialsPerSession { get; set; }

        /// <summary>How often to review</summary>
        public string ReviewSchedule { get; set; }

        /// <summary>Last review date</summary>
        public DateTime? LastReviewDate { get; set; }

        /// <summary>Next review date</summary>
        public DateTime? NextReviewDate { get; set; }

        /// <summary>Criteria for switching phases</summary>
        public string SwitchCriteria { get; set; }

        /// <summary>Program notes</summary>
        public string Notes { get; set; }

        // Navigation properties
        public virtual Case Case { get; set; }
        public virtual Behavior Behavior { get; set; }
        public virtual Goal Goal { get; set; }
        public virtual ReplacementSkill ReplacementSkill { get; set; }
        public virtual List<Session> Sessions { get; set; } = new();
        public virtual List<DataPoint> DataPoints { get; set; } = new();
        public virtual List<ProgressReport> ProgressReports { get; set; } = new();
    }

    /// <summary>Program Status</summary>
    public enum ProgramStatus
    {
        Active,          // Currently active
        OnHold,          // Temporarily paused
        Completed,       // Successfully completed
        Discontinued,    // Discontinued
        Maintenance      // Maintenance phase
    }
}
