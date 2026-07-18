using System;
using SNA.Domain.Entities.Core;

namespace SNA.Domain.Entities.BehaviorAnalysis
{
    /// <summary>
    /// Functional Behavior Assessment - ABC Analysis
    /// A = Antecedent (what happened before)
    /// B = Behavior (the behavior itself)
    /// C = Consequence (what happened after)
    /// </summary>
    public class BehaviorABC : BaseEntity
    {
        /// <summary>The behavior being analyzed</summary>
        public Guid BehaviorId { get; set; }

        /// <summary>What happened before the behavior</summary>
        public string Antecedent { get; set; }

        /// <summary>Description of the behavior</summary>
        public string Behavior { get; set; }

        /// <summary>What happened after the behavior</summary>
        public string Consequence { get; set; }

        /// <summary>Identified function</summary>
        public BehaviorFunction Function { get; set; }

        /// <summary>Detailed description of the function</summary>
        public string FunctionDescription { get; set; }

        /// <summary>Therapist's hypothesis</summary>
        public string Hypothesis { get; set; }

        /// <summary>Has this been validated by the BCBA?</summary>
        public bool ValidatedByBCBA { get; set; } = false;

        /// <summary>When this ABC analysis was identified</summary>
        public DateTime DateIdentified { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual Behavior BehaviorNavigation { get; set; }
    }
}
