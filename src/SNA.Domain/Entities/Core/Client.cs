using System;
using System.Collections.Generic;

namespace SNA.Domain.Entities.Core
{
    /// <summary>
    /// Client Entity - Represents a child/student receiving services
    /// </summary>
    public class Client : BaseEntity
    {
        /// <summary>Client Code for easy reference</summary>
        public string ClientCode { get; set; }

        /// <summary>First name</summary>
        public string FirstName { get; set; }

        /// <summary>Last name</summary>
        public string LastName { get; set; }

        /// <summary>Date of birth</summary>
        public DateTime DateOfBirth { get; set; }

        /// <summary>Gender</summary>
        public string Gender { get; set; }

        /// <summary>Age group (calculated from DOB)</summary>
        public string AgeGroup { get; set; }

        /// <summary>Primary diagnosis</summary>
        public string PrimaryDiagnosis { get; set; }

        /// <summary>Secondary diagnosis</summary>
        public string SecondaryDiagnosis { get; set; }

        /// <summary>Primary parent/guardian</summary>
        public Guid? PrimaryParentId { get; set; }

        /// <summary>Secondary parent/guardian</summary>
        public Guid? SecondaryParentId { get; set; }

        /// <summary>School name</summary>
        public string School { get; set; }

        /// <summary>Grade level</summary>
        public string Grade { get; set; }

        /// <summary>Enrollment date</summary>
        public DateTime EnrollmentDate { get; set; }

        /// <summary>Current status</summary>
        public ClientStatus Status { get; set; }

        /// <summary>General notes about the client</summary>
        public string Notes { get; set; }

        // Navigation properties
        public virtual List<Case> Cases { get; set; } = new();
    }

    /// <summary>Client Status</summary>
    public enum ClientStatus
    {
        Active,
        Inactive,
        Graduated,
        Discharged
    }
}
