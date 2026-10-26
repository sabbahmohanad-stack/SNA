using System;

namespace SNA.Domain.Entities.Core
{
    /// <summary>Clinical or behavioral diagnosis associated with a case.</summary>
    public class Diagnosis : BaseEntity
    {
        public Guid CaseId { get; set; }
        public string DiagnosisType { get; set; }
        public string ICD10Code { get; set; }
        public string DSMVCode { get; set; }
        public string DiagnosisLabel { get; set; }
        public DateTime DiagnosisDate { get; set; }
        public string ClinicalDescription { get; set; }
        public string DSMCriteria { get; set; }
        public int? Severity { get; set; }
        public string Diagnostician { get; set; }
        public Guid? RelatedAssessmentId { get; set; }
        public bool IsPrimary { get; set; }
        public DiagnosisStatus Status { get; set; } = DiagnosisStatus.Active;

        public virtual Case Case { get; set; }
        public virtual Assessment RelatedAssessment { get; set; }
    }

    public enum DiagnosisStatus
    {
        Active,
        Archived,
        Disputed
    }
}
