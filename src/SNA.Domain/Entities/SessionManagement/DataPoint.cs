using System;
using SNA.Domain.Entities.BehaviorAnalysis;
using SNA.Domain.Entities.Core;
using SNA.Domain.Entities.ProgramManagement;

namespace SNA.Domain.Entities.SessionManagement
{
    /// <summary>
    /// Data Point - Individual trial/observation data collected during sessions
    /// This is the foundation of all measurement and progress monitoring
    /// </summary>
    public class DataPoint : BaseEntity
    {
        /// <summary>Session this data was collected in</summary>
        public Guid SessionId { get; set; }

        /// <summary>Behavior being measured</summary>
        public Guid BehaviorId { get; set; }

        /// <summary>Program this data belongs to (optional)</summary>
        public Guid? ProgramId { get; set; }

        /// <summary>Trial number</summary>
        public int TrialNumber { get; set; }

        /// <summary>Response to the trial</summary>
        public TrialResponse Response { get; set; }

        /// <summary>Prompt used</summary>
        public string PromptUsed { get; set; }

        /// <summary>Prompt level (1-5)</summary>
        public int? PromptLevel { get; set; }

        /// <summary>Latency in milliseconds</summary>
        public int? Latency { get; set; }

        /// <summary>Duration in milliseconds</summary>
        public int? Duration { get; set; }

        /// <summary>Quality of response (1-5 scale)</summary>
        public int? Quality { get; set; }

        /// <summary>Independence level percentage</summary>
        public decimal? IndependenceLevel { get; set; }

        /// <summary>Notes about this trial</summary>
        public string Notes { get; set; }

        /// <summary>Time this data was recorded</summary>
        public TimeSpan? RecordedTime { get; set; }

        /// <summary>Therapist who recorded this data</summary>
        public Guid RecordedByTherapistId { get; set; }

        // Navigation properties
        public virtual Session Session { get; set; }
        public virtual Behavior Behavior { get; set; }
        public virtual Program Program { get; set; }
    }

    /// <summary>Response codes for trials</summary>
    public enum TrialResponse
    {
        Correct,         // Correct response
        Incorrect,       // Incorrect response
        Partial,         // Partially correct
        Refused,         // Client refused
        NoOpportunity    // No opportunity to respond
    }
}
