using System;
using System.Collections.Generic;
using SNA.Domain.Entities.Core;
using SNA.Domain.Entities.ProgramManagement;

namespace SNA.Domain.Entities.BehaviorAnalysis
{
    /// <summary>
    /// Replacement Skill - What should be taught instead of the inappropriate behavior
    /// </summary>
    public class ReplacementSkill : BaseEntity
    {
        /// <summary>The behavior being replaced</summary>
        public Guid BehaviorId { get; set; }

        /// <summary>Name of the replacement skill</summary>
        public string SkillName { get; set; }

        /// <summary>Operational definition of the skill</summary>
        public string OperationalDefinition { get; set; }

        /// <summary>Description of the skill</summary>
        public string SkillDescription { get; set; }

        /// <summary>Why this skill replaces the behavior</summary>
        public string Rationale { get; set; }

        /// <summary>How to teach this skill</summary>
        public string TeachingMethod { get; set; }

        /// <summary>Step-by-step teaching steps</summary>
        public string TeachingSteps { get; set; }

        /// <summary>Prerequisites needed</summary>
        public string Prerequisites { get; set; }

        /// <summary>Materials needed for teaching</summary>
        public string MaterialsNeeded { get; set; }

        /// <summary>Starting prompt level</summary>
        public PromptLevel PromptLevel { get; set; }

        /// <summary>Target mastery percentage</summary>
        public decimal MasteryTarget { get; set; } = 80;

        /// <summary>Current status</summary>
        public SkillStatus Status { get; set; } = SkillStatus.Planning;

        /// <summary>When teaching started</summary>
        public DateTime? DateStarted { get; set; }

        /// <summary>When skill was mastered</summary>
        public DateTime? DateMastered { get; set; }

        // Navigation properties
        public virtual Behavior Behavior { get; set; }
        public virtual List<PromptHierarchy> PromptHierarchies { get; set; } = new();
        public virtual List<Program> Programs { get; set; } = new();
    }

    /// <summary>Prompt Level for teaching</summary>
    public enum PromptLevel
    {
        FullPhysical,
        PartialPhysical,
        Gestural,
        Verbal,
        Independence
    }

    /// <summary>Skill Status</summary>
    public enum SkillStatus
    {
        Planning,        // Planning phase
        Teaching,        // Active teaching
        Generalizing,    // Working on generalization
        Maintained,      // Skill is maintained
        Mastered,        // Skill mastered
        Discontinued     // No longer teaching
    }
}
