using System;
using System.Collections.Generic;
using SNA.Domain.Entities.Core;

namespace SNA.Domain.Entities.BehaviorAnalysis
{
    /// <summary>
    /// Behavior Entity - Core behavior definition and tracking
    /// </summary>
    public class Behavior : BaseEntity
    {
        /// <summary>Case this behavior belongs to</summary>
        public Guid CaseId { get; set; }

        /// <summary>Related baseline (optional)</summary>
        public Guid? BaselineId { get; set; }

        /// <summary>Name of the behavior</summary>
        public string BehaviorName { get; set; }

        /// <summary>MUST be specific and observable definition</summary>
        public string OperationalDefinition { get; set; }

        /// <summary>Type of behavior</summary>
        public BehaviorType BehaviorType { get; set; }

        /// <summary>Identified function of the behavior</summary>
        public BehaviorFunction Function { get; set; }

        /// <summary>Severity rating (1-10)</summary>
        public int Severity { get; set; } = 5;

        /// <summary>How often the behavior occurs</summary>
        public string Frequency { get; set; }

        /// <summary>Duration of the behavior (in seconds/minutes)</summary>
        public int? Duration { get; set; }

        /// <summary>Latency - how long until behavior starts</summary>
        public int? Latency { get; set; }

        /// <summary>Intensity of the behavior (1-10)</summary>
        public int? Intensity { get; set; }

        /// <summary>Current mastery level (0-100%)</summary>
        public decimal MasteryLevel { get; set; } = 0;

        /// <summary>Current status of behavior</summary>
        public BehaviorStatus Status { get; set; } = BehaviorStatus.Baseline;

        /// <summary>Related replacement skill (if any)</summary>
        public Guid? LinkedReplacementSkillId { get; set; }

        /// <summary>When this behavior was identified</summary>
        public DateTime DateIdentified { get; set; }

        /// <summary>When behavior was mastered (if applicable)</summary>
        public DateTime? DateMastered { get; set; }

        // Navigation properties
        public virtual Case Case { get; set; }
        public virtual Baseline Baseline { get; set; }
        public virtual List<BehaviorABC> ABCAnalyses { get; set; } = new();
        public virtual List<ReplacementSkill> ReplacementSkills { get; set; } = new();
        public virtual List<Program> Programs { get; set; } = new();
        public virtual List<DataPoint> DataPoints { get; set; } = new();
        public virtual List<GeneralizationSetting> GeneralizationSettings { get; set; } = new();
    }

    /// <summary>Behavior Type</summary>
    public enum BehaviorType
    {
        Inappropriate,   // Behavior to reduce
        Replacement,     // Behavior to teach as replacement
        Target,          // Target behavior to increase
        Desirable        // Already desirable behavior
    }

    /// <summary>Behavior Function (why the behavior occurs)</summary>
    public enum BehaviorFunction
    {
        Escape,          // To avoid or escape something
        Attention,       // To get attention
        Tangible,        // To obtain something tangible
        Sensory,         // Self-stimulatory/sensory
        None,            // No clear function
        Unknown          // Not yet determined
    }

    /// <summary>Behavior Status</summary>
    public enum BehaviorStatus
    {
        Baseline,        // Data collection phase
        Teaching,        // Active intervention
        Generalizing,    // Working on generalization
        Maintained,      // Maintaining gains
        Mastered,        // Goal achieved
        Discontinued     // No longer tracking
    }
}
