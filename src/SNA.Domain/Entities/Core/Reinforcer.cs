using System;

namespace SNA.Domain.Entities.Core
{
    /// <summary>A potential reinforcer available for a case.</summary>
    public class Reinforcer : BaseEntity
    {
        public Guid CaseId { get; set; }
        public string ReinforcerName { get; set; }
        public string ReinforcerType { get; set; }
        public string Description { get; set; }
        public int? PreferenceStrength { get; set; }
        public string Schedule { get; set; }
        public int? ScheduleValue { get; set; }
        public string DeliveryMethod { get; set; }
        public string CostToDeliver { get; set; }
        public string Status { get; set; } = "Active";
        public DateTime DateAdded { get; set; } = DateTime.UtcNow.Date;
        public DateTime? DateDiscontinued { get; set; }

        public virtual Case Case { get; set; }
    }
}
