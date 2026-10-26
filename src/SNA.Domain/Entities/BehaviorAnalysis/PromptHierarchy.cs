using System;
using SNA.Domain.Entities.Core;

namespace SNA.Domain.Entities.BehaviorAnalysis
{
    /// <summary>Defines the order and guidance for fading prompts.</summary>
    public class PromptHierarchy : BaseEntity
    {
        public Guid ReplacementSkillId { get; set; }
        public int Level { get; set; }
        public string PromptDescription { get; set; }
        public string PromptInstructions { get; set; }
        public string Effectiveness { get; set; }
        public string FadingStrategy { get; set; }
        public int Order { get; set; }

        public virtual ReplacementSkill ReplacementSkill { get; set; }
    }
}
