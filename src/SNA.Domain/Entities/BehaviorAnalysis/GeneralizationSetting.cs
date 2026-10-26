using System;
using SNA.Domain.Entities.Core;

namespace SNA.Domain.Entities.BehaviorAnalysis
{
    /// <summary>Tracks generalization of a behavior across settings.</summary>
    public class GeneralizationSetting : BaseEntity
    {
        public Guid BehaviorId { get; set; }
        public string SettingType { get; set; }
        public string SettingDescription { get; set; }
        public string People { get; set; }
        public string Materials { get; set; }
        public decimal? SuccessRate { get; set; }
        public DateTime? DateStarted { get; set; }
        public DateTime? DateAchieved { get; set; }
        public GeneralizationStatus Status { get; set; } = GeneralizationStatus.Planning;
        public string Notes { get; set; }

        public virtual Behavior Behavior { get; set; }
    }

    public enum GeneralizationStatus
    {
        Planning,
        InProgress,
        Achieved
    }
}
