using System;
using System.Collections.Generic;
using SNA.Domain.Entities.Core;
using SNA.Domain.Entities.ProgramManagement;

namespace SNA.Domain.Entities.SessionManagement
{
    /// <summary>
    /// Session Entity - Therapy/intervention session
    /// </summary>
    public class Session : BaseEntity
    {
        /// <summary>The case this session belongs to</summary>
        public Guid CaseId { get; set; }

        /// <summary>The program being worked on (optional)</summary>
        public Guid? ProgramId { get; set; }

        /// <summary>Date of the session</summary>
        public DateTime SessionDate { get; set; }

        /// <summary>Sequential session number for this case</summary>
        public int SessionNumber { get; set; }

        /// <summary>Start time of session</summary>
        public TimeSpan? StartTime { get; set; }

        /// <summary>End time of session</summary>
        public TimeSpan? EndTime { get; set; }

        /// <summary>Duration in minutes (calculated)</summary>
        public int? DurationMinutes { get; set; }

        /// <summary>Therapist who conducted the session</summary>
        public Guid TherapistId { get; set; }

        /// <summary>Supervising BCBA (optional)</summary>
        public Guid? SupervisingBCBAId { get; set; }

        /// <summary>Location of session</summary>
        public string Location { get; set; }

        /// <summary>Type of service delivery</summary>
        public ServiceType ServiceType { get; set; }

        /// <summary>Percentage of session dedicated to program adherence</summary>
        public decimal? AdherencePercentage { get; set; }

        /// <summary>General notes on client behavior</summary>
        public string ClientBehavior { get; set; }

        /// <summary>Challenges encountered</summary>
        public string Challenges { get; set; }

        /// <summary>General session notes</summary>
        public string Notes { get; set; }

        /// <summary>Session status</summary>
        public SessionStatus Status { get; set; } = SessionStatus.Completed;

        /// <summary>If cancelled, reason for cancellation</summary>
        public string CancellationReason { get; set; }

        // Navigation properties
        public virtual Case Case { get; set; }
        public virtual Program Program { get; set; }
        public virtual List<DataPoint> DataPoints { get; set; } = new();
    }

    /// <summary>Service Type</summary>
    public enum ServiceType
    {
        OneToOne,        // 1:1 session
        Group,           // Group session
        ParentCoaching,  // Parent coaching session
        Indirect         // Indirect service (planning, etc.)
    }

    /// <summary>Session Status</summary>
    public enum SessionStatus
    {
        Completed,       // Session completed
        Cancelled,       // Session was cancelled
        NoShow,          // Client did not show
        Pending          // Session pending (future)
    }
}
