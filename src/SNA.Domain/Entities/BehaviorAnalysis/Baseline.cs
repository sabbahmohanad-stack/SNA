using System;
using System.Collections.Generic;
using SNA.Domain.Entities.Core;

namespace SNA.Domain.Entities.BehaviorAnalysis
{
    /// <summary>Baseline observations used before an intervention begins.</summary>
    public class Baseline : BaseEntity
    {
        public Guid CaseId { get; set; }
        public string BehaviorDescription { get; set; }
        public string OperationalDefinition { get; set; }
        public DateTime DateInitiated { get; set; }
        public decimal? BaselineFrequency { get; set; }
        public int? BaselineDuration { get; set; }
        public int? BaselineLatency { get; set; }
        public int? BaselineIntensity { get; set; }
        public string Context { get; set; }
        public int? TrialsPerSession { get; set; } = 10;
        public string CompletionCriteria { get; set; }
        public BaselineStatus Status { get; set; } = BaselineStatus.Active;

        public virtual Case Case { get; set; }
        public virtual List<Behavior> Behaviors { get; set; } = new();
    }

    public enum BaselineStatus
    {
        Active,
        Completed,
        Discontinued
    }
}
