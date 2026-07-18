# SNA: Entity-Relationship Diagram (EER)

## 🏛️ CASE-CENTRIC ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────────────┐
│                          CASE (Core Entity)                          │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ • CaseID (PK)                                               │  │
│  │ • CaseNumber (Unique, Human-Readable)                       │  │
│  │ • Status (Active/Inactive/Discharged/Suspended)            │  │
│  │ • OpenDate, DischargeDate                                   │  │
│  │ • CreatedBy, UpdatedBy, Timestamp                           │  │
│  │ • Version, IsDeleted (Soft Delete)                          │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
          ↓                    ↓                    ↓
    ┌─────────────┐    ┌─────────────┐    ┌──────────────────┐
    │   CLIENT    │    │  CASE TEAM  │    │  ASSESSMENTS     │
    ├─────────────┤    ├─────────────┤    ├──────────────────┤
    │ • ClientID  │    │ • CaseTeamID│    │ • AssessmentID   │
    │ • FirstName │    │ • UserID(FK)│    │ • AssessmentType │
    │ • LastName  │    │ • Role      │    │ • Date Completed │
    │ • DOB       │    │ • DateAdded │    │ • Assessor       │
    │ • AgeGroup  │    │ • IsActive  │    │ • Result/Score   │
    │ • ParentID  │    └─────────────┘    │ • Interpretation │
    └─────────────┘                       │ • Recommendations│
          ↑                                │ • ToolUsed       │
          │                                └──────────────────┘
          │                                        ↓
          └────────────────────────────────────────────────┐
                                                            │
                                                   ┌────────┴──────────┐
                                                   │                   │
                                            ┌──────────────┐   ┌─────────────┐
                                            │ DIAGNOSIS    │   │ BASELINE    │
                                            ├──────────────┤   ├─────────────┤
                                            │ • DiagnosisID│   │ • BaselineID│
                                            │ • ICD10Code  │   │ • BehaviorID│
                                            │ • Description│   │ • Frequency │
                                            │ • DSMCriteria│   │ • Duration  │
                                            │ • Severity   │   │ • Intensity │
                                            │ • Date       │   │ • Context   │
                                            └──────────────┘   │ • Measured  │
                                                                └─────────────┘
                                                                        ↓
                                                                        
┌──────────────────────────────────────────────────────────────────────────┐
│                    BEHAVIOR ANALYSIS CORE STRUCTURE                      │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │                      BEHAVIOR                                   │  │
│  │  ┌──────────────────────────────────────────────────────────┐  │  │
│  │  │ • BehaviorID (PK)              (CASE-specific)          │  │  │
│  │  │ • OperationalDefinition (detailed description)          │  │  │
│  │  │ • BehaviorType (Inappropriate/Replacement/Target)       │  │  │
│  │  │ • Function (Escape/Attention/Tangible/Sensory/None)    │  │  │
│  │  │ • Severity (1-10 scale)                                 │  │  │
│  │  │ • MasteryLevel (0-100%)                                 │  │  │
│  │  │ • Status (Baseline/Teaching/Generalizing/Maintained)    │  │  │
│  │  │ • CreatedDate, LastModified                             │  │  │
│  │  └──────────────────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│           ↓                              ↓                 ↓            │
│  ┌─────────────────┐         ┌──────────────────┐   ┌──────────────┐   │
│  │    ABC MODEL    │         │ REPLACEMENT SKILL│   │ PROMPT HIER. │   │
│  ├─────────────────┤         ├──────────────────┤   ├──────────────┤   │
│  │ • ABCID (PK)    │         │ • SkillID (PK)   │   │ • PromptID   │   │
│  │ • Antecedent    │         │ • SkillName      │   │ • Level 1-5  │   │
│  │ • Behavior      │         │ • Definition     │   │ • Strategy   │   │
│  │ • Consequence   │         │ • TeachingPlan   │   │ • Effectiveness│  │
│  │ • Function      │         │ • Prerequisite   │   │ • DateAdded  │   │
│  │ • DateIdentified│         │ • MasteryTarget  │   └──────────────┘   │
│  └─────────────────┘         └──────────────────┘                       │
│                                                                          │
│  ┌─────────────────────┐         ┌──────────────────────────────────┐  │
│  │  REINFORCEMENT      │         │  GENERALIZATION SETTING          │  │
│  ├─────────────────────┤         ├──────────────────────────────────┤  │
│  │ • ReinforcerID (PK) │         │ • GeneralizationID (PK)          │  │
│  │ • Type (Tangible)   │         │ • Setting (Home/School/Community)│  │
│  │ • Schedule (VI/FR)  │         │ • People (Parents/Siblings/Peers)│  │
│  │ • Delivery          │         │ • Materials (Different/Similar)  │  │
│  │ • Preference        │         │ • Success Rate                   │  │
│  │ • Strength (1-10)   │         │ • DateStarted                    │  │
│  └─────────────────────┘         └──────────────────────────────────┘  │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘

                                    ↓

┌──────────────────────────────────────────────────────────────────┐
│                    PROGRAM (Intervention Plan)                   │
├──────────────────────────────────────────────────────────────────┤
│ • ProgramID (PK)                                                 │
│ • ProgramName                                                    │
│ • BehaviorID (FK) - links to specific behavior                   │
│ • ReplacementSkillID (FK)                                        │
│ • StartDate, TargetEndDate, ActualEndDate                        │
│ • Status (Active/Completed/OnHold/Discontinued)                  │
│ • MasteryTarget (threshold %)                                    │
│ • DataCollectionMethod (Frequency/Duration/Latency/etc)          │
│ • ReviewSchedule (Weekly/BiWeekly/Monthly)                       │
│ • CreatedBy, LastReviewed                                        │
└──────────────────────────────────────────────────────────────────┘
                    ↓                          ↓
        ┌───────────────────┐      ┌────────────────────┐
        │      SESSION      │      │    GOAL (IEP/ISP)  │
        ├───────────────────┤      ├────────────────────┤
        │ • SessionID (PK)  │      │ • GoalID (PK)      │
        │ • SessionDate     │      │ • GoalStatement    │
        │ • StartTime       │      │ • Objective        │
        │ • EndTime         │      │ • MeasurementMethod│
        │ • Duration        │      │ • CriteriaForMastery│
        │ • TherapistID(FK) │      │ • Timeline         │
        │ • Location        │      │ • Status           │
        │ • Notes           │      │ • RelatedPrograms  │
        │ • ProgramID(FK)   │      │ • Progress%        │
        │ • Status (Done)   │      └────────────────────┘
        └───────────────────┘
                ↓
    ┌────────────────────────────┐
    │   DATA COLLECTION POINT    │
    ├────────────────────────────┤
    │ • DataPointID (PK)         │
    │ • SessionID (FK)           │
    │ • BehaviorID (FK)          │
    │ • TrialNumber              │
    │ • Response (Correct/Inc)   │
    │ • PromptUsed               │
    │ • TimeRecorded             │
    │ • Notes                    │
    │ • Percentage (calc)        │
    └────────────────────────────┘
                ↓
    ┌──────────────────────────┐
    │  PROGRESS REPORT         │
    ├──────────────────────────┤
    │ • ReportID (PK)          │
    │ • ProgramID (FK)         │
    │ • ReportDate             │
    │ • PerformanceChange      │
    │ • GraphData (JSON)       │
    │ • Summary                │
    │ • Recommendations        │
    │ • NextReview             │
    └──────────────────────────┘
```

---

## 📋 Table Structure Overview

### **Core Tables**
1. `Cases` - The foundation entity
2. `Clients` - Child/Student information
3. `CaseTeam` - Team members assigned to case
4. `Users` - System users (BCBA, Therapist, Admin)

### **Assessment & Diagnosis**
5. `Assessments` - Initial evaluations
6. `Diagnoses` - Clinical diagnosis
7. `Baselines` - Baseline measurements

### **Behavior Analysis**
8. `Behaviors` - Behavior definitions
9. `BehaviorABC` - ABC functional analysis
10. `ReplacementSkills` - Skills to teach
11. `PromptHierarchy` - Prompt levels
12. `Reinforcers` - Reinforcement strategies
13. `GeneralizationSettings` - Settings for generalization

### **Intervention & Execution**
14. `Programs` - Treatment programs
15. `Goals` - IEP/ISP goals
16. `Sessions` - Therapy sessions
17. `DataPoints` - Data collection records

### **Monitoring & Reporting**
18. `ProgressReports` - Progress summaries
19. `BehaviorGraphData` - Graph data for visualization

### **System Tables**
20. `AuditLog` - Change tracking
21. `SystemSettings` - Configuration

---

## 🔑 Key Relationships

| Relationship | Cardinality | Notes |
|--------------|-------------|-------|
| Case → Client | N:1 | One case per client (multiple cases if re-enrolled) |
| Case → Assessments | 1:N | One case has many assessments |
| Case → Diagnosis | 1:N | Multiple diagnoses per case |
| Case → Behaviors | 1:N | Core behaviors identified in case |
| Behavior → Programs | 1:N | One behavior in multiple programs |
| Behavior → DataPoints | 1:N | Behavior tracked across sessions |
| Program → Sessions | 1:N | Program executed in sessions |
| Program → Goals | 1:N | Goals related to program |
| Session → DataPoints | 1:N | Data collected in sessions |
| Program → ProgressReports | 1:N | Reports generated from programs |

---

## 🔒 Audit & Compliance

Every table includes:
- `CreatedDate` - When created
- `CreatedByUserID` - Who created it
- `ModifiedDate` - Last modification
- `ModifiedByUserID` - Who modified it
- `IsDeleted` - Soft delete flag
- `Version` - Optimistic concurrency
- `RowVersion` - SQL Server timestamp

---

## ✅ Next Steps

1. SQL CREATE TABLE statements
2. C# Domain Models & Entities
3. EF Core Configuration
4. Migrations setup
5. Repository Pattern implementation
