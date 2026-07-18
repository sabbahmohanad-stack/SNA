using System;
using SNA.Domain.Entities.Core;
using SNA.Domain.Entities.ProgramManagement;

namespace SNA.Domain.Entities.Reporting
{
    /// <summary>
    /// Progress Report Entity - Aggregate data and analysis for progress monitoring
    /// </summary>
    public class ProgressReport : BaseEntity
    {
        /// <summary>The case this report is for</summary>
        public Guid CaseId { get; set; }

        /// <summary>The program this report covers (optional)</summary>
        public Guid? ProgramId { get; set; }

        /// <summary>Type of report</summary>
        public ReportType ReportType { get; set; }

        /// <summary>Date the report was generated</summary>
        public DateTime ReportDate { get; set; }

        /// <summary>Start date of reporting period</summary>
        public DateTime PeriodStartDate { get; set; }

        /// <summary>End date of reporting period</summary>
        public DateTime PeriodEndDate { get; set; }

        /// <summary>Summary of data (JSON format)</summary>
        public string DataSummary { get; set; }

        /// <summary>Percentage change from previous period</summary>
        public decimal? PerformanceChange { get; set; }

        /// <summary>Trend analysis</summary>
        public TrendAnalysis TrendAnalysis { get; set; }

        /// <summary>Is the program on track?</summary>
        public MasteryStatus MasteryStatus { get; set; }

        /// <summary>Graph data in JSON format</summary>
        public string GraphDataJSON { get; set; }

        /// <summary>Summary narrative</summary>
        public string Summary { get; set; }

        /// <summary>Recommendations for next steps</summary>
        public string Recommendations { get; set; }

        /// <summary>Challenges encountered</summary>
        public string Challenges { get; set; }

        /// <summary>Next steps</summary>
        public string NextSteps { get; set; }

        /// <summary>Next review date</summary>
        public DateTime? NextReviewDate { get; set; }

        /// <summary>BCBA who approved the report</summary>
        public Guid? ApprovedByBCBAId { get; set; }

        /// <summary>When was the report approved</summary>
        public DateTime? ApprovalDate { get; set; }

        /// <summary>Was this shared with parent?</summary>
        public bool SharedWithParent { get; set; } = false;

        /// <summary>When was it shared with parent?</summary>
        public DateTime? ParentSharedDate { get; set; }

        // Navigation properties
        public virtual Case Case { get; set; }
        public virtual Program Program { get; set; }
    }

    /// <summary>Report Type</summary>
    public enum ReportType
    {
        Weekly,
        BiWeekly,
        Monthly,
        Quarterly,
        IEP,
        Annual
    }

    /// <summary>Trend Analysis</summary>
    public enum TrendAnalysis
    {
        Improving,       // Positive trend
        Stable,          // No significant change
        Declining        // Negative trend
    }

    /// <summary>Mastery Status</summary>
    public enum MasteryStatus
    {
        OnTrack,         // On pace to meet mastery target
        Delayed,         // Behind schedule
        Accelerated,     // Ahead of schedule
        Mastered,        // Goal achieved
        Discontinued     // Program discontinued
    }
}
