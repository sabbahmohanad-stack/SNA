# Database Relationships & Dependencies

## Core Entity Relationships

### CASE at Center
```
CASE (1:N) --> Behaviors
CASE (1:N) --> Programs
CASE (1:N) --> Sessions
CASE (1:N) --> Goals
CASE (1:N) --> Assessments
CASE (1:N) --> Diagnoses
CASE (1:N) --> Reinforcers
```

### Behavior Analysis Flow
```
Baseline (1:1) --> Behavior
  |
  ├--> BehaviorABC (1:N) [Functional Analysis]
  |
  ├--> ReplacementSkill (1:N) [What to teach]
  |     |
  |     └--> PromptHierarchy (1:N) [How to teach]
  |
  ├--> Program (1:N) [Treatment plan]
  |     |
  |     └--> Session (1:N) [Delivery]
  |           |
  |           └--> DataPoints (1:N) [Measurement]
  |
  └--> GeneralizationSettings (1:N) [Real-world application]
```

### Program Execution
```
Program (1:N) --> Sessions
Program (1:N) --> DataPoints
Program (1:1) --> Goal [Related to]
Program (1:1) --> ProgressReport
Program (1:N) --> ProgressReport [Multiple reports over time]
```

### Goal Tracking
```
Goal (M:N) --> Behaviors [Multiple behaviors may address one goal]
Goal (1:N) --> ProgressReports
Goal --> MasteryTarget (percentage)
```

### Session Data Collection
```
Session (1:N) --> DataPoints
DataPoint --> Behavior [What was measured]
DataPoint --> Program [Part of which program]
DataPoint --> Response [Correct/Incorrect]
DataPoint --> PromptLevel [How much help given]
```

## Critical Constraints

### Data Integrity Rules

1. **Case Integrity**
   - Cannot delete Case while it has active Programs
   - Cannot close Case without completing ProgressReports
   - Must have at least one Behavior defined

2. **Behavior Integrity**
   - Must have OperationalDefinition (specific, observable)
   - Must have at least one Baseline
   - Cannot delete Behavior with active Programs
   - Must have identified Function (or mark as "Unknown")

3. **Program Integrity**
   - Must have linked Behavior
   - Must have defined MasteryTarget
   - Cannot complete without minimum Sessions
   - Must have final ProgressReport before closure

4. **Data Collection Integrity**
   - Cannot record DataPoints for non-existent Behavior
   - Cannot record DataPoints after Program ends
   - Each DataPoint must have Response code
   - Response codes must match defined vocabulary

5. **Goal Integrity**
   - Must have specific MeasurementMethod
   - Must have clear CriteriaForMastery
   - Cannot delete active Goal
   - Must update ProgressPercentage regularly

## Foreign Key Relationships

```
Cases
  ├── ClientId --> Clients.ClientId (N:1)
  ├── CaseManager_BCBAId --> Users.UserId (N:1)
  └── SupervisoryBCBAId --> Users.UserId (N:1)

Behaviors
  ├── CaseId --> Cases.CaseId (N:1)
  ├── BaselineId --> Baselines.BaselineId (N:1, optional)
  └── LinkedReplacementSkillId --> ReplacementSkills.ReplacementSkillId (1:1)

Programs
  ├── CaseId --> Cases.CaseId (N:1)
  ├── BehaviorId --> Behaviors.BehaviorId (N:1)
  ├── RelatedGoalId --> Goals.GoalId (N:1, optional)
  └── ReplacementSkillId --> ReplacementSkills.ReplacementSkillId (N:1, optional)

Sessions
  ├── CaseId --> Cases.CaseId (N:1)
  ├── ProgramId --> Programs.ProgramId (N:1, optional)
  ├── TherapistId --> Users.UserId (N:1)
  └── SupervisingBCBAId --> Users.UserId (N:1, optional)

DataPoints
  ├── SessionId --> Sessions.SessionId (N:1)
  ├── BehaviorId --> Behaviors.BehaviorId (N:1)
  ├── ProgramId --> Programs.ProgramId (N:1, optional)
  └── RecordedByTherapistId --> Users.UserId (N:1)

ProgressReports
  ├── CaseId --> Cases.CaseId (N:1)
  ├── ProgramId --> Programs.ProgramId (N:1, optional)
  └── ApprovedByBCBAId --> Users.UserId (N:1, optional)
```

## Cascade Rules

### Soft Delete (IsDeleted = 1)
All deletes are soft deletes. When a record is marked deleted:
- Associated views exclude it
- Queries filter out deleted records
- Historical data remains in AuditLog
- No data is permanently lost

### Hard Constraints
Some relationships prevent deletion:
- Cannot delete User if they created records (CreatedByUserId FK)
- Cannot delete Case if it has Programs with Sessions
- Cannot delete Behavior if it has Programs in progress

## Normalization Strategy

### Third Normal Form (3NF)
- No transitive dependencies
- All dependencies on primary key
- No repeating groups

### Data Redundancy Avoided
- MasteryLevel on Behavior (not recalculated in Program)
- Frequency/Duration stored once with Baseline
- Names stored in one place (Users, Clients, etc.)

### Calculated Fields (NOT stored, calculated on-demand)
- Session DurationMinutes (EndTime - StartTime)
- AgeGroup (calculated from DOB)
- AccuracyPercentage (from DataPoints)
- MasteryStatus (from DataPoints vs. Target)
- ProgressPercentage (from DataPoints)
- PerformanceChange (from previous ProgressReport)

## Temporal Considerations

### Date Tracking
- All entities have CreatedDate, ModifiedDate
- Sessions have SessionDate (when it occurred)
- Programs have StartDate, TargetEndDate, ActualEndDate
- DataPoints have RecordedTime (when data was recorded)
- AuditLog tracks all changes with ChangeDate

### Time Zones
- All times stored in UTC (DATETIME2)
- Client-side converts to local timezone
- DST handled automatically

## Archival Strategy

### Completed Cases
- Never deleted
- Status = "Closed" or "Discharged"
- IsDeleted = 0 (still retrievable)
- Historical data preserved for:
  - Progress tracking
  - Re-enrollment
  - Research
  - Compliance

## Performance Optimization

### Indexes Created
1. Foreign Key indexes for JOINs
2. Status indexes for filtering
3. Date indexes for range queries
4. User indexes for access control
5. Case indexes for case-centric queries

### Query Optimization
- Use views for common queries
- Avoid N+1 queries with includes
- Batch DataPoint inserts
- Cache frequently accessed lookups

## Data Hierarchy

```
Organization
  └── Clinic/Center
      └── CASE
          ├── CLIENT
          ├── TEAM (CaseTeamMembers)
          ├── ASSESSMENTS & DIAGNOSES
          ├── BEHAVIORS
          │   ├── ABC Analysis
          │   ├── Baseline
          │   ├── Replacement Skills
          │   │   └── Prompt Hierarchy
          │   ├── Reinforcers
          │   └── Generalization Settings
          ├── GOALS
          ├── PROGRAMS
          │   └── SESSIONS
          │       └── DATA POINTS
          └── PROGRESS REPORTS
```
