using System;
using System.Collections.Generic;
using SNA.Domain.Entities.BehaviorAnalysis;
using SNA.Domain.Entities.ProgramManagement;
using SNA.Domain.Entities.Reporting;
using SNA.Domain.Entities.SessionManagement;

namespace SNA.Domain.Entities.Core
{
    /// <summary>
    /// Case Entity - The core entity that contains everything
    /// All behaviors, programs, goals, sessions, and data revolve around CASE
    /// </summary>
    public class Case : BaseEntity
    {
        /// <summary>Case Number (Unique, Human-Readable: CASE-YYYY-MM-000001)</summary>
        public string CaseNumber { get; set; }

        /// <summary>Reference to the Client</summary>
        public Guid ClientId { get; set; }

        /// <summary>Status of the case</summary>
        public CaseStatus Status { get; set; }

        /// <summary>When the case was opened</summary>
        public DateTime OpenDate { get; set; }

        /// <summary>When the case was closed (if applicable)</summary>
        public DateTime? ClosureDate { get; set; }

        /// <summary>When the client was discharged from services</summary>
        public DateTime? DischargeDate { get; set; }

        /// <summary>Reason for case closure</summary>
        public string ReasonForClosure { get; set; }

        /// <summary>Case Manager (must be BCBA)</summary>
        public Guid CaseManagerBCBAId { get; set; }

        /// <summary>Supervisory BCBA (optional)</summary>
        public Guid? SupervisoryBCBAId { get; set; }

        /// <summary>Initial intake notes</summary>
        public string IntakeNotes { get; set; }

        /// <summary>Clinic or center location</summary>
        public string ClinicLocation { get; set; }

        /// <summary>How services are delivered</summary>
        public ServiceDeliveryModel ServiceDeliveryModel { get; set; }

        /// <summary>Frequency per week</summary>
        public int FrequencyPerWeek { get; set; }

        /// <summary>Duration of each session in minutes</summary>
        public int SessionDurationMinutes { get; set; }

        // Navigation properties
        public virtual Client Client { get; set; }
        public virtual List<Behavior> Behaviors { get; set; } = new();
        public virtual List<Program> Programs { get; set; } = new();
        public virtual List<Session> Sessions { get; set; } = new();
        public virtual List<Goal> Goals { get; set; } = new();
        public virtual List<Assessment> Assessments { get; set; } = new();
        public virtual List<Diagnosis> Diagnoses { get; set; } = new();
        public virtual List<Reinforcer> Reinforcers { get; set; } = new();
        public virtual List<ProgressReport> ProgressReports { get; set; } = new();
        public virtual List<CaseTeamMember> TeamMembers { get; set; } = new();
    }

    /// <summary>Case Status Enumeration</summary>
    public enum CaseStatus
    {
        Active,
        OnHold,
        Suspended,
        Closed,
        Discharged
    }

    /// <summary>Service Delivery Model</summary>
    public enum ServiceDeliveryModel
    {
        OneToOne,
        Group,
        Hybrid
    }
}
