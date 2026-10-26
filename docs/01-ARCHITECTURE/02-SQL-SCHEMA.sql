-- =====================================================================
-- SNA: Special Education & ABA Platform
-- Database Schema - SQL Server
-- =====================================================================

-- =====================================================================
-- SYSTEM TABLES
-- =====================================================================

-- Users table (extends ASP.NET Identity)
CREATE TABLE [Users] (
    [UserId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [UserName] NVARCHAR(256) NOT NULL UNIQUE,
    [Email] NVARCHAR(256) NOT NULL UNIQUE,
    [FirstName] NVARCHAR(100) NOT NULL,
    [LastName] NVARCHAR(100) NOT NULL,
    [PhoneNumber] NVARCHAR(20),
    [Role] NVARCHAR(50) NOT NULL, -- BCBA, Therapist, Admin, SuperAdmin, Parent, Observer
    [License] NVARCHAR(100), -- For BCBA certification
    [LicenseExpiry] DATE,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedByUserId] UNIQUEIDENTIFIER,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1
);

CREATE INDEX IX_Users_Email ON [Users]([Email]);
CREATE INDEX IX_Users_Role ON [Users]([Role]);

-- =====================================================================
-- CLIENT ENTITIES
-- =====================================================================

-- Clients table (Children/Students)
CREATE TABLE [Clients] (
    [ClientId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [ClientCode] NVARCHAR(50) NOT NULL UNIQUE, -- For easy reference
    [FirstName] NVARCHAR(100) NOT NULL,
    [LastName] NVARCHAR(100) NOT NULL,
    [DateOfBirth] DATE NOT NULL,
    [Gender] NVARCHAR(20), -- Male, Female, Other
    [AgeGroup] NVARCHAR(20), -- Calculated from DOB (0-3, 3-6, 6-12, 12+)
    [PrimaryDiagnosis] NVARCHAR(255),
    [SecondaryDiagnosis] NVARCHAR(255),
    [PrimaryParentId] UNIQUEIDENTIFIER, -- FK to Users (Parent)
    [SecondaryParentId] UNIQUEIDENTIFIER, -- FK to Users (Optional Parent)
    [School] NVARCHAR(255),
    [Grade] NVARCHAR(50),
    [EnrollmentDate] DATE NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Active', -- Active, Inactive, Graduated, Discharged
    [Notes] NVARCHAR(MAX),
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedByUserId] UNIQUEIDENTIFIER,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Clients_PrimaryParent FOREIGN KEY ([PrimaryParentId]) REFERENCES [Users]([UserId]),
    CONSTRAINT FK_Clients_SecondaryParent FOREIGN KEY ([SecondaryParentId]) REFERENCES [Users]([UserId]),
    CONSTRAINT FK_Clients_CreatedBy FOREIGN KEY ([CreatedByUserId]) REFERENCES [Users]([UserId])
);

CREATE INDEX IX_Clients_ClientCode ON [Clients]([ClientCode]);
CREATE INDEX IX_Clients_Status ON [Clients]([Status]);

-- =====================================================================
-- CASE MANAGEMENT (CORE)
-- =====================================================================

-- Cases table (Core Entity - Everything revolves around this)
CREATE TABLE [Cases] (
    [CaseId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [CaseNumber] NVARCHAR(50) NOT NULL UNIQUE, -- Format: CASE-YYYY-MM-000001
    [ClientId] UNIQUEIDENTIFIER NOT NULL,
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Active', -- Active, OnHold, Suspended, Closed, Discharged
    [OpenDate] DATE NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
    [ClosureDate] DATE,
    [DischargeDate] DATE,
    [ReasonForClosure] NVARCHAR(MAX),
    [CaseManager_BCBAId] UNIQUEIDENTIFIER NOT NULL, -- FK to Users (Must be BCBA)
    [SupervisoryBCBAId] UNIQUEIDENTIFIER, -- FK to Users (BCBA Supervisor)
    [IntakeNotes] NVARCHAR(MAX),
    [ClinicLocation] NVARCHAR(255),
    [ServiceDeliveryModel] NVARCHAR(50), -- 1:1, Group, Hybrid
    [FrequencyPerWeek] INT,
    [SessionDurationMinutes] INT,
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedByUserId] UNIQUEIDENTIFIER,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Cases_Client FOREIGN KEY ([ClientId]) REFERENCES [Clients]([ClientId]),
    CONSTRAINT FK_Cases_CaseManager FOREIGN KEY ([CaseManager_BCBAId]) REFERENCES [Users]([UserId]),
    CONSTRAINT FK_Cases_SupervisoryBCBA FOREIGN KEY ([SupervisoryBCBAId]) REFERENCES [Users]([UserId])
);

CREATE INDEX IX_Cases_CaseNumber ON [Cases]([CaseNumber]);
CREATE INDEX IX_Cases_ClientId ON [Cases]([ClientId]);
CREATE INDEX IX_Cases_Status ON [Cases]([Status]);
CREATE INDEX IX_Cases_OpenDate ON [Cases]([OpenDate]);

-- Case Team Members
CREATE TABLE [CaseTeamMembers] (
    [CaseTeamMemberId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [CaseId] UNIQUEIDENTIFIER NOT NULL,
    [UserId] UNIQUEIDENTIFIER NOT NULL,
    [Role] NVARCHAR(50) NOT NULL, -- BCBA, Therapist, Supervisor, Observer, Consultant
    [DateAssigned] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [DateUnassigned] DATETIME2,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedByUserId] UNIQUEIDENTIFIER,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_CaseTeam_Case FOREIGN KEY ([CaseId]) REFERENCES [Cases]([CaseId]),
    CONSTRAINT FK_CaseTeam_User FOREIGN KEY ([UserId]) REFERENCES [Users]([UserId]),
    CONSTRAINT FK_CaseTeam_CreatedBy FOREIGN KEY ([CreatedByUserId]) REFERENCES [Users]([UserId]),
    CONSTRAINT PK_CaseTeamMembers UNIQUE ([CaseId], [UserId])
);

-- =====================================================================
-- ASSESSMENT & DIAGNOSIS
-- =====================================================================

-- Assessments table
CREATE TABLE [Assessments] (
    [AssessmentId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [CaseId] UNIQUEIDENTIFIER NOT NULL,
    [AssessmentType] NVARCHAR(100) NOT NULL, -- ABLLS-R, VB-MAPP, GARS, CARS, ADOS, etc.
    [AssessmentName] NVARCHAR(255) NOT NULL,
    [DateAdministered] DATE NOT NULL,
    [DateCompleted] DATE,
    [AssessorId] UNIQUEIDENTIFIER NOT NULL, -- FK to Users
    [TotalScore] DECIMAL(10, 2),
    [PercentileRank] DECIMAL(10, 2),
    [StandardScore] DECIMAL(10, 2),
    [AgeEquivalent] NVARCHAR(50),
    [KeyFindings] NVARCHAR(MAX), -- Summary of main findings
    [Strengths] NVARCHAR(MAX),
    [Weaknesses] NVARCHAR(MAX),
    [Recommendations] NVARCHAR(MAX),
    [AssessmentDocument] NVARCHAR(MAX), -- URL or blob reference
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Pending', -- Pending, Completed, Archived
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedByUserId] UNIQUEIDENTIFIER,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Assessments_Case FOREIGN KEY ([CaseId]) REFERENCES [Cases]([CaseId]),
    CONSTRAINT FK_Assessments_Assessor FOREIGN KEY ([AssessorId]) REFERENCES [Users]([UserId])
);

CREATE INDEX IX_Assessments_CaseId ON [Assessments]([CaseId]);
CREATE INDEX IX_Assessments_DateAdministered ON [Assessments]([DateAdministered]);

-- Diagnoses table
CREATE TABLE [Diagnoses] (
    [DiagnosisId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [CaseId] UNIQUEIDENTIFIER NOT NULL,
    [DiagnosisType] NVARCHAR(50) NOT NULL, -- Clinical, Behavioral, Learning
    [ICD10Code] NVARCHAR(20),
    [DSMVCode] NVARCHAR(20),
    [DiagnosisLabel] NVARCHAR(255) NOT NULL, -- e.g., "Autism Spectrum Disorder"
    [DiagnosisDate] DATE NOT NULL,
    [ClinicalDescription] NVARCHAR(MAX),
    [DSMCriteria] NVARCHAR(MAX),
    [Severity] INT, -- 1-10 or Mild, Moderate, Severe
    [Diagnostician] NVARCHAR(255), -- External clinician if applicable
    [RelatedAssessmentId] UNIQUEIDENTIFIER, -- FK to Assessments (may be null)
    [IsPrimary] BIT NOT NULL DEFAULT 0,
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Active', -- Active, Archived, Disputed
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedByUserId] UNIQUEIDENTIFIER,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Diagnoses_Case FOREIGN KEY ([CaseId]) REFERENCES [Cases]([CaseId]),
    CONSTRAINT FK_Diagnoses_Assessment FOREIGN KEY ([RelatedAssessmentId]) REFERENCES [Assessments]([AssessmentId])
);

CREATE INDEX IX_Diagnoses_CaseId ON [Diagnoses]([CaseId]);

-- =====================================================================
-- BEHAVIOR ANALYSIS
-- =====================================================================

-- Baselines table
CREATE TABLE [Baselines] (
    [BaselineId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [CaseId] UNIQUEIDENTIFIER NOT NULL,
    [BehaviorDescription] NVARCHAR(255) NOT NULL,
    [OperationalDefinition] NVARCHAR(MAX) NOT NULL,
    [DateInitiated] DATE NOT NULL,
    [BaselineFrequency] DECIMAL(10, 2), -- Occurrences per hour/day
    [BaselineDuration] INT, -- Duration in seconds/minutes
    [BaselineLatency] INT, -- How long before behavior starts
    [BaselineIntensity] INT, -- 1-10 scale
    [Context] NVARCHAR(MAX), -- Where/when behavior occurs
    [TrialsPerSession] INT DEFAULT 10,
    [CompletionCriteria] NVARCHAR(255),
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Active', -- Active, Completed, Discontinued
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedByUserId] UNIQUEIDENTIFIER,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Baselines_Case FOREIGN KEY ([CaseId]) REFERENCES [Cases]([CaseId])
);

CREATE INDEX IX_Baselines_CaseId ON [Baselines]([CaseId]);

-- Behaviors table (Core behavior tracking)
CREATE TABLE [Behaviors] (
    [BehaviorId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [CaseId] UNIQUEIDENTIFIER NOT NULL,
    [BaselineId] UNIQUEIDENTIFIER, -- FK to Baselines
    [BehaviorName] NVARCHAR(255) NOT NULL,
    [OperationalDefinition] NVARCHAR(MAX) NOT NULL, -- MUST be specific and observable
    [BehaviorType] NVARCHAR(50) NOT NULL, -- Inappropriate, Replacement, Target, Desirable
    [Function] NVARCHAR(100), -- Escape, Attention, Tangible, Sensory, None/Unknown
    [Severity] INT NOT NULL DEFAULT 5, -- 1-10 scale
    [Frequency] NVARCHAR(50), -- How often per hour/day/week
    [Duration] INT, -- In seconds/minutes
    [Latency] INT, -- How long until behavior starts
    [Intensity] INT, -- 1-10 scale
    [MasteryLevel] DECIMAL(10, 2) NOT NULL DEFAULT 0, -- Percentage (0-100%)
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Baseline', -- Baseline, Teaching, Generalizing, Maintained, Mastered, Discontinued
    [LinkedReplacementSkillId] UNIQUEIDENTIFIER, -- FK to ReplacementSkills
    [DateIdentified] DATE NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
    [DateMastered] DATE,
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedByUserId] UNIQUEIDENTIFIER,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Behaviors_Case FOREIGN KEY ([CaseId]) REFERENCES [Cases]([CaseId]),
    CONSTRAINT FK_Behaviors_Baseline FOREIGN KEY ([BaselineId]) REFERENCES [Baselines]([BaselineId])
);

CREATE INDEX IX_Behaviors_CaseId ON [Behaviors]([CaseId]);
CREATE INDEX IX_Behaviors_Status ON [Behaviors]([Status]);

-- ABC Analysis (Functional Behavior Assessment)
CREATE TABLE [BehaviorABC] (
    [ABCId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [BehaviorId] UNIQUEIDENTIFIER NOT NULL,
    [Antecedent] NVARCHAR(MAX) NOT NULL, -- What happened before
    [Behavior] NVARCHAR(MAX) NOT NULL, -- The behavior itself
    [Consequence] NVARCHAR(MAX) NOT NULL, -- What happened after
    [Function] NVARCHAR(100), -- Escape, Attention, Tangible, Sensory, None/Unknown
    [FunctionDescription] NVARCHAR(MAX),
    [Hypothesis] NVARCHAR(MAX), -- Therapist's hypothesis about why
    [ValidatedByBCBA] BIT NOT NULL DEFAULT 0,
    [DateIdentified] DATE NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedByUserId] UNIQUEIDENTIFIER,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_BehaviorABC_Behavior FOREIGN KEY ([BehaviorId]) REFERENCES [Behaviors]([BehaviorId])
);

CREATE INDEX IX_BehaviorABC_BehaviorId ON [BehaviorABC]([BehaviorId]);

-- Replacement Skills
CREATE TABLE [ReplacementSkills] (
    [ReplacementSkillId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [BehaviorId] UNIQUEIDENTIFIER NOT NULL, -- FK to Behaviors (inappropriate behavior being replaced)
    [SkillName] NVARCHAR(255) NOT NULL,
    [OperationalDefinition] NVARCHAR(MAX) NOT NULL,
    [SkillDescription] NVARCHAR(MAX),
    [Rationale] NVARCHAR(MAX), -- Why this skill replaces the behavior
    [TeachingMethod] NVARCHAR(MAX), -- How to teach it
    [TeachingSteps] NVARCHAR(MAX), -- Step-by-step breakdown
    [Prerequisites] NVARCHAR(MAX), -- Skills needed first
    [MaterialsNeeded] NVARCHAR(MAX),
    [PromptLevel] NVARCHAR(20), -- Full Physical, Partial Physical, Gestural, Verbal, Independence
    [MasteryTarget] DECIMAL(10, 2) NOT NULL DEFAULT 80, -- Percentage for mastery
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Planning', -- Planning, Teaching, Generalizing, Maintained, Mastered
    [DateStarted] DATE,
    [DateMastered] DATE,
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedByUserId] UNIQUEIDENTIFIER,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_ReplacementSkills_Behavior FOREIGN KEY ([BehaviorId]) REFERENCES [Behaviors]([BehaviorId])
);

CREATE INDEX IX_ReplacementSkills_BehaviorId ON [ReplacementSkills]([BehaviorId]);

-- Prompt Hierarchy
CREATE TABLE [PromptHierarchy] (
    [PromptHierarchyId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [ReplacementSkillId] UNIQUEIDENTIFIER NOT NULL,
    [Level] INT NOT NULL, -- 1, 2, 3, 4, 5
    [PromptDescription] NVARCHAR(255) NOT NULL, -- Full Physical, Partial Physical, Gestural, Verbal, Independence
    [PromptInstructions] NVARCHAR(MAX), -- Detailed how-to
    [Effectiveness] NVARCHAR(20), -- High, Medium, Low
    [FadingStrategy] NVARCHAR(MAX), -- How to reduce prompt over time
    [Order] INT NOT NULL, -- Sequential order for fading
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedByUserId] UNIQUEIDENTIFIER,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_PromptHierarchy_ReplacementSkill FOREIGN KEY ([ReplacementSkillId]) REFERENCES [ReplacementSkills]([ReplacementSkillId])
);

-- Reinforcers
CREATE TABLE [Reinforcers] (
    [ReinforcerId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [CaseId] UNIQUEIDENTIFIER NOT NULL,
    [ReinforcerName] NVARCHAR(255) NOT NULL,
    [ReinforcerType] NVARCHAR(50) NOT NULL, -- Tangible, Activity, Social, Sensory, Token
    [Description] NVARCHAR(MAX),
    [PreferenceStrength] INT, -- 1-10 scale
    [Schedule] NVARCHAR(100), -- VI (Variable Interval), VR (Variable Ratio), FI, FR
    [ScheduleValue] INT, -- For VI/VR/FI/FR (e.g., VI-30 seconds = 30)
    [DeliveryMethod] NVARCHAR(MAX), -- How/when delivered
    [CostToDeliver] NVARCHAR(50), -- Low, Medium, High
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Active', -- Active, Inactive, Discontinued, Outdated
    [DateAdded] DATE NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
    [DateDiscontinued] DATE,
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedByUserId] UNIQUEIDENTIFIER,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Reinforcers_Case FOREIGN KEY ([CaseId]) REFERENCES [Cases]([CaseId])
);

CREATE INDEX IX_Reinforcers_CaseId ON [Reinforcers]([CaseId]);

-- Generalization Settings
CREATE TABLE [GeneralizationSettings] (
    [GeneralizationSettingId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [BehaviorId] UNIQUEIDENTIFIER NOT NULL,
    [SettingType] NVARCHAR(100) NOT NULL, -- Home, School, Community, Public, Work
    [SettingDescription] NVARCHAR(255),
    [People] NVARCHAR(MAX), -- Parents, Siblings, Peers, Teachers, Strangers
    [Materials] NVARCHAR(MAX), -- Same/Different from teaching materials
    [SuccessRate] DECIMAL(10, 2), -- Percentage
    [DateStarted] DATE,
    [DateAchieved] DATE,
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Planning', -- Planning, InProgress, Achieved
    [Notes] NVARCHAR(MAX),
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedByUserId] UNIQUEIDENTIFIER,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_GeneralizationSettings_Behavior FOREIGN KEY ([BehaviorId]) REFERENCES [Behaviors]([BehaviorId])
);

CREATE INDEX IX_GeneralizationSettings_BehaviorId ON [GeneralizationSettings]([BehaviorId]);

-- =====================================================================
-- GOALS & PROGRAMS
-- =====================================================================

-- Goals (IEP/ISP Goals)
CREATE TABLE [Goals] (
    [GoalId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [CaseId] UNIQUEIDENTIFIER NOT NULL,
    [GoalNumber] INT NOT NULL, -- Goal 1, Goal 2, etc.
    [GoalStatement] NVARCHAR(MAX) NOT NULL,
    [DomainArea] NVARCHAR(100) NOT NULL, -- Communication, Social, Academic, Motor, Behavior, Self-Care, Vocational
    [ObjectiveStatement] NVARCHAR(MAX),
    [MeasurementMethod] NVARCHAR(255), -- Frequency, Duration, Latency, Percentage, Yes/No
    [CriteriaForMastery] NVARCHAR(255), -- e.g., "80% accuracy for 3 consecutive sessions"
    [DataCollectionSchedule] NVARCHAR(100), -- Daily, Weekly, Bi-weekly, Monthly
    [Timeline] INT, -- Weeks to achieve
    [TargetDate] DATE,
    [StartDate] DATE NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
    [EndDate] DATE,
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Active', -- Active, Achieved, Modified, Discontinued, Archived
    [ProgressPercentage] DECIMAL(10, 2) NOT NULL DEFAULT 0,
    [RelatedBehaviorIds] NVARCHAR(MAX), -- JSON array of BehaviorIds
    [IEPReviewDate] DATE,
    [Notes] NVARCHAR(MAX),
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedByUserId] UNIQUEIDENTIFIER,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Goals_Case FOREIGN KEY ([CaseId]) REFERENCES [Cases]([CaseId])
);

CREATE INDEX IX_Goals_CaseId ON [Goals]([CaseId]);
CREATE INDEX IX_Goals_Status ON [Goals]([Status]);

-- Programs (Treatment/Intervention Programs)
CREATE TABLE [Programs] (
    [ProgramId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [CaseId] UNIQUEIDENTIFIER NOT NULL,
    [ProgramName] NVARCHAR(255) NOT NULL,
    [BehaviorId] UNIQUEIDENTIFIER NOT NULL, -- FK to Behaviors
    [RelatedGoalId] UNIQUEIDENTIFIER, -- FK to Goals (optional)
    [ReplacementSkillId] UNIQUEIDENTIFIER, -- FK to ReplacementSkills
    [ProgramDescription] NVARCHAR(MAX),
    [StartDate] DATE NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
    [TargetEndDate] DATE,
    [ActualEndDate] DATE,
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Active', -- Active, OnHold, Completed, Discontinued, Maintenance
    [MasteryTarget] DECIMAL(10, 2) NOT NULL DEFAULT 80, -- Percentage for mastery
    [DataCollectionMethod] NVARCHAR(100), -- Frequency, Duration, Latency, Percentage, Trials, Errors
    [TrialsPerSession] INT,
    [ReviewSchedule] NVARCHAR(100), -- Weekly, BiWeekly, Monthly
    [LastReviewDate] DATE,
    [NextReviewDate] DATE,
    [SwitchCriteria] NVARCHAR(MAX), -- When to move to next phase
    [Notes] NVARCHAR(MAX),
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedByUserId] UNIQUEIDENTIFIER,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Programs_Case FOREIGN KEY ([CaseId]) REFERENCES [Cases]([CaseId]),
    CONSTRAINT FK_Programs_Behavior FOREIGN KEY ([BehaviorId]) REFERENCES [Behaviors]([BehaviorId]),
    CONSTRAINT FK_Programs_Goal FOREIGN KEY ([RelatedGoalId]) REFERENCES [Goals]([GoalId]),
    CONSTRAINT FK_Programs_ReplacementSkill FOREIGN KEY ([ReplacementSkillId]) REFERENCES [ReplacementSkills]([ReplacementSkillId])
);

CREATE INDEX IX_Programs_CaseId ON [Programs]([CaseId]);
CREATE INDEX IX_Programs_BehaviorId ON [Programs]([BehaviorId]);
CREATE INDEX IX_Programs_Status ON [Programs]([Status]);

-- =====================================================================
-- SESSIONS & DATA COLLECTION
-- =====================================================================

-- Sessions
CREATE TABLE [Sessions] (
    [SessionId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [CaseId] UNIQUEIDENTIFIER NOT NULL,
    [ProgramId] UNIQUEIDENTIFIER, -- FK to Programs (optional, session may not have program)
    [SessionDate] DATE NOT NULL,
    [SessionNumber] INT, -- Sequential session number for this case
    [StartTime] TIME(0),
    [EndTime] TIME(0),
    [DurationMinutes] INT, -- Calculated
    [TherapistId] UNIQUEIDENTIFIER NOT NULL, -- FK to Users
    [SupervisingBCBAId] UNIQUEIDENTIFIER, -- FK to Users (optional - if BCBA present)
    [Location] NVARCHAR(255),
    [ServiceType] NVARCHAR(50), -- 1:1, Group, Parent Coaching, Indirect
    [AdherencePercentage] DECIMAL(10, 2), -- % of session dedicated to program
    [ClientBehavior] NVARCHAR(MAX), -- General notes on client behavior
    [Challenges] NVARCHAR(MAX),
    [Notes] NVARCHAR(MAX),
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Completed', -- Completed, Cancelled, NoShow, Pending
    [CancellationReason] NVARCHAR(MAX),
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedByUserId] UNIQUEIDENTIFIER,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Sessions_Case FOREIGN KEY ([CaseId]) REFERENCES [Cases]([CaseId]),
    CONSTRAINT FK_Sessions_Program FOREIGN KEY ([ProgramId]) REFERENCES [Programs]([ProgramId]),
    CONSTRAINT FK_Sessions_Therapist FOREIGN KEY ([TherapistId]) REFERENCES [Users]([UserId]),
    CONSTRAINT FK_Sessions_SupervisingBCBA FOREIGN KEY ([SupervisingBCBAId]) REFERENCES [Users]([UserId])
);

CREATE INDEX IX_Sessions_CaseId ON [Sessions]([CaseId]);
CREATE INDEX IX_Sessions_SessionDate ON [Sessions]([SessionDate]);
CREATE INDEX IX_Sessions_TherapistId ON [Sessions]([TherapistId]);
CREATE INDEX IX_Sessions_Status ON [Sessions]([Status]);

-- Data Points (Individual trial/observation data)
CREATE TABLE [DataPoints] (
    [DataPointId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [SessionId] UNIQUEIDENTIFIER NOT NULL,
    [BehaviorId] UNIQUEIDENTIFIER NOT NULL,
    [ProgramId] UNIQUEIDENTIFIER, -- FK to Programs
    [TrialNumber] INT, -- 1st trial, 2nd trial, etc.
    [Response] NVARCHAR(50) NOT NULL, -- Correct, Incorrect, Partial, Refused, NoOpportunity
    [PromptUsed] NVARCHAR(100), -- Full Physical, Partial Physical, Gestural, Verbal, Independence
    [PromptLevel] INT, -- 1-5 corresponding to hierarchy
    [Latency] INT, -- Milliseconds or seconds
    [Duration] INT, -- Duration in milliseconds
    [Quality] INT, -- 1-5 scale for response quality
    [IndependenceLevel] DECIMAL(10, 2), -- Percentage independent
    [Notes] NVARCHAR(MAX),
    [RecordedTime] TIME(0),
    [RecordedByTherapistId] UNIQUEIDENTIFIER, -- FK to Users (who recorded it)
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_DataPoints_Session FOREIGN KEY ([SessionId]) REFERENCES [Sessions]([SessionId]),
    CONSTRAINT FK_DataPoints_Behavior FOREIGN KEY ([BehaviorId]) REFERENCES [Behaviors]([BehaviorId]),
    CONSTRAINT FK_DataPoints_Program FOREIGN KEY ([ProgramId]) REFERENCES [Programs]([ProgramId]),
    CONSTRAINT FK_DataPoints_RecordedBy FOREIGN KEY ([RecordedByTherapistId]) REFERENCES [Users]([UserId])
);

CREATE INDEX IX_DataPoints_SessionId ON [DataPoints]([SessionId]);
CREATE INDEX IX_DataPoints_BehaviorId ON [DataPoints]([BehaviorId]);
CREATE INDEX IX_DataPoints_CreatedDate ON [DataPoints]([CreatedDate]);

-- =====================================================================
-- PROGRESS MONITORING & REPORTING
-- =====================================================================

-- Progress Reports
CREATE TABLE [ProgressReports] (
    [ProgressReportId] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [CaseId] UNIQUEIDENTIFIER NOT NULL,
    [ProgramId] UNIQUEIDENTIFIER, -- FK to Programs
    [ReportType] NVARCHAR(50), -- Weekly, BiWeekly, Monthly, Quarterly, IEP
    [ReportDate] DATE NOT NULL,
    [PeriodStartDate] DATE NOT NULL,
    [PeriodEndDate] DATE NOT NULL,
    [DataSummary] NVARCHAR(MAX), -- JSON with aggregated data
    [PerformanceChange] DECIMAL(10, 2), -- % change from previous period
    [TrendAnalysis] NVARCHAR(MAX), -- Improving, Stable, Declining
    [MasteryStatus] NVARCHAR(20), -- On Track, Delayed, Accelerated, Mastered, Discontinued
    [GraphDataJSON] NVARCHAR(MAX), -- JSON for charting
    [Summary] NVARCHAR(MAX),
    [Recommendations] NVARCHAR(MAX),
    [Challenges] NVARCHAR(MAX),
    [NextSteps] NVARCHAR(MAX),
    [NextReviewDate] DATE,
    [ApprovedByBCBAId] UNIQUEIDENTIFIER, -- FK to Users (BCBA approval)
    [ApprovalDate] DATETIME2,
    [SharedWithParent] BIT NOT NULL DEFAULT 0,
    [ParentSharedDate] DATETIME2,
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    [Version] INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_ProgressReports_Case FOREIGN KEY ([CaseId]) REFERENCES [Cases]([CaseId]),
    CONSTRAINT FK_ProgressReports_Program FOREIGN KEY ([ProgramId]) REFERENCES [Programs]([ProgramId]),
    CONSTRAINT FK_ProgressReports_ApprovedByBCBA FOREIGN KEY ([ApprovedByBCBAId]) REFERENCES [Users]([UserId])
);

CREATE INDEX IX_ProgressReports_CaseId ON [ProgressReports]([CaseId]);
CREATE INDEX IX_ProgressReports_ReportDate ON [ProgressReports]([ReportDate]);

-- =====================================================================
-- AUDIT & SYSTEM TABLES
-- =====================================================================

-- Audit Log
CREATE TABLE [AuditLog] (
    [AuditLogId] BIGINT PRIMARY KEY IDENTITY(1,1),
    [TableName] NVARCHAR(100) NOT NULL,
    [RecordId] NVARCHAR(100) NOT NULL,
    [Operation] NVARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    [OldValues] NVARCHAR(MAX), -- JSON
    [NewValues] NVARCHAR(MAX), -- JSON
    [ChangedByUserId] UNIQUEIDENTIFIER NOT NULL,
    [ChangeDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [IPAddress] NVARCHAR(50),
    [Reason] NVARCHAR(MAX)
);

CREATE INDEX IX_AuditLog_ChangeDate ON [AuditLog]([ChangeDate]);
CREATE INDEX IX_AuditLog_TableName ON [AuditLog]([TableName]);

-- System Settings
CREATE TABLE [SystemSettings] (
    [SettingId] INT PRIMARY KEY IDENTITY(1,1),
    [SettingKey] NVARCHAR(100) NOT NULL UNIQUE,
    [SettingValue] NVARCHAR(MAX) NOT NULL,
    [Description] NVARCHAR(500),
    [SettingType] NVARCHAR(50), -- String, Int, Boolean, DateTime
    [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

-- =====================================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================================

CREATE INDEX IX_Behaviors_MasteryLevel ON [Behaviors]([MasteryLevel]);
CREATE INDEX IX_ReplacementSkills_Status ON [ReplacementSkills]([Status]);
CREATE INDEX IX_Programs_LastReviewDate ON [Programs]([LastReviewDate]);
CREATE INDEX IX_Goals_ProgressPercentage ON [Goals]([ProgressPercentage]);
CREATE INDEX IX_DataPoints_Response ON [DataPoints]([Response]);

-- =====================================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================================

-- View: Current Active Cases
CREATE VIEW vw_ActiveCases AS
SELECT 
    c.CaseId,
    c.CaseNumber,
    c.ClientId,
    cl.FirstName + ' ' + cl.LastName AS ClientName,
    c.Status,
    c.OpenDate,
    c.CaseManager_BCBAId,
    u.FirstName + ' ' + u.LastName AS BCBAName,
    c.ServiceDeliveryModel,
    c.FrequencyPerWeek
FROM [Cases] c
INNER JOIN [Clients] cl ON c.ClientId = cl.ClientId
INNER JOIN [Users] u ON c.CaseManager_BCBAId = u.UserId
WHERE c.Status = 'Active' AND c.IsDeleted = 0;

-- View: Program Progress Summary
CREATE VIEW vw_ProgramProgress AS
SELECT 
    p.ProgramId,
    p.ProgramName,
    p.CaseId,
    p.BehaviorId,
    b.BehaviorName,
    b.MasteryLevel,
    p.MasteryTarget,
    p.Status,
    COUNT(dp.DataPointId) AS TrialsCompleted,
    SUM(CASE WHEN dp.Response = 'Correct' THEN 1 ELSE 0 END) AS CorrectResponses,
    CAST(SUM(CASE WHEN dp.Response = 'Correct' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(dp.DataPointId), 0) AS DECIMAL(10, 2)) AS AccuracyPercentage
FROM [Programs] p
LEFT JOIN [Behaviors] b ON p.BehaviorId = b.BehaviorId
LEFT JOIN [DataPoints] dp ON p.ProgramId = dp.ProgramId
WHERE p.IsDeleted = 0
GROUP BY p.ProgramId, p.ProgramName, p.CaseId, p.BehaviorId, b.BehaviorName, b.MasteryLevel, p.MasteryTarget, p.Status;
